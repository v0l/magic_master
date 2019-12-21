import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:magic_master/const.dart';
import 'package:magic_master/karaoke_config.dart';
import 'package:magic_master/song_manager.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

enum BrokerState {
  Disconnected,
  Connected,
  ReservationCountChange,
}

class Broker {
  static Broker _instance = Broker();
  static Broker get instance => _instance;

  final StreamController<BrokerState> stateChange =
      StreamController.broadcast();

  final Queue<Completer<List<Song>>> _reservationRequests = Queue();

  MqttClient _mqtt;
  KaraokeConfig config;
  int _lstRvlCount;

  Broker({
    this.config,
  });

  bool get isConnected =>
      config != null &&
      (_mqtt?.connectionStatus?.state == MqttConnectionState.connected ??
          false);

  Future<void> start(KaraokeConfig cfg) async {
    if (cfg != null) {
      config = cfg;

      final id = await getMqttId();
      if (!isConnected) {
        _mqtt = MqttClient(config.broker, id);
        _mqtt.onConnected = () {
          stateChange.add(BrokerState.Connected);
        };
        _mqtt.onDisconnected = () async {
          stateChange.add(BrokerState.Disconnected);

          //try re-connect
          try {
            await Future.delayed(Duration(seconds: 1));
            await _mqtt.connect();
          } catch (ex) {
            print(ex);
          }
        };
        final status = await _mqtt.connect();
        if (status.state != MqttConnectionState.connected) {
          throw "Failed to connect to ${config.broker}: ${status.returnCode.toString()}";
        }

        _mqtt.updates.listen((msgs) {
          for (var msg in msgs) {
            if (msg.topic.startsWith(MobileTopicStart)) {
              if (msg.payload is MqttPublishMessage) {
                final data = utf8.decode(
                    (msg.payload as MqttPublishMessage).payload.message);
                print(data);
                _handleDeviceMessage(data);
              }
            }
          }
        });
        _mqtt.subscribe(await getAppTopic(), MqttQos.atMostOnce);
        await _sendKAR();
        //sends WHO also
        await getReservationList();
      } else {
        // device topic stays the same so no need to change if already connected
        // only publishes will change dest
        // push a WHO command to the new karaoke
        // push a CMD for revlist
        await _sendKAR();
        //sends WHO also
        await getReservationList();
      }

      //all done
    }
  }

  Future<void> _sendKAR() async {
    final appTopic = await getAppTopic();
    _sendString(appTopic, "KAR${config.toJson()}");
  }

  //WHO{"MOBILEID":"iOS/F6083BB7-F828-4277-B3C4-148445802259","EMAIL":"xxx","MOBILESYS":1}
  //WHO{"MOBILEID":"Android/ffffffff-ba68-c20a-5a2e-09622d143630","EMAIL":"xxx","MOBILESYS":1}
  Future<void> _sendWWO() async {
    final devId = await getMqttId();
    final karTopic = getKaraokeTopic();

    final jObj = <String, dynamic>{
      "MOBILEID": devId,
      "EMAIL": "",
      "MOBILESYS": 1,
    };

    _sendString(karTopic, "WHO${json.encode(jObj)}");
  }

  int get reservationCount => _lstRvlCount;

  void _handleDeviceMessage(String data) {
    //map this to List<Song>
    //RVL{"RESERVCOUNT":1,"NUMBER":[10692],"NATION":[7],"TYPE":[1],"TITLE":["IKAW"],"SINGER":["YENG CONSTANTINO"]}
    if (data.startsWith("RVL")) {
      final ret = List<Song>();
      final jData = json.decode(data.substring(3));
      final rCount = jData["RESERVCOUNT"] as int;
      if (rCount > 0) {
        final numbers = jData["NUMBER"].cast<int>();
        final nations = jData["NATION"].cast<int>();
        final types = jData["TYPE"].cast<int>();
        final titles = jData["TITLE"].cast<String>();
        final singers = jData["SINGER"].cast<String>();

        for (var x = 0; x < rCount; x++) {
          ret.add(Song(
            number: numbers[x],
            nation: nations[x],
            songType: types[x],
            title: titles[x],
            artist: singers[x],
          ));
        }
      }

      //push list to all completers
      while (_reservationRequests.length > 0) {
        final req = _reservationRequests.removeFirst();
        req.complete(ret);
      }

      if (_lstRvlCount != rCount) {
        _lstRvlCount = rCount;
        stateChange.add(BrokerState.ReservationCountChange);
      }
    }
  }

  int _sendString(String topic, String data) {
    if ((topic?.isEmpty ?? true) || !isConnected) throw "Not connected";
    print("Sending $topic => $data");

    final builder = MqttClientPayloadBuilder();
    builder.addUTF8String(data);
    return _mqtt.publishMessage(topic, MqttQos.atMostOnce, builder.payload);
  }

  Future<void> startFromConfig() async {
    if (_mqtt == null) {
      final pref = await SharedPreferences.getInstance();

      //try to load KaraokeConfig from settings
      final cfgJson = pref.getString(KaraokeInfo);
      if (cfgJson?.isNotEmpty ?? false) {
        final cfg = KaraokeConfig.fromJson(cfgJson);
        if (cfg != null) {
          await start(cfg);
        }
      }

      //nothing to do, no karaoke known
    }
  }

  void playSong(Song s) {
    if (s != null && isConnected) {
      _sendString(getKaraokeTopic(), "PLY${s.toSongRequestJson()}");
    }
  }

  void reserveSong(Song s) {
    if (s != null && isConnected) {
      _sendString(getKaraokeTopic(), "RES${s.toSongRequestJson()}");
    }
  }

  //RCL{"SONGNUMBER":3009,"SONGNATION":7,"SONGTYPE":1,"ACCOUNTVALID":0,"FORMAT":0,"SONGTITLE":"MASDAN MO ANG KAPALIGIRAN","SONGSINGER":"AEGIS"}
  void removeReservedSong(Song s) {
    if (s != null && isConnected) {
      _sendString(getKaraokeTopic(), "RCL${s.toSongRequestJson()}");
    }
  }

  Future<String> getMqttId() async {
    String mqttId;
    if (Platform.isIOS) {
      mqttId = "IOS/${await getDeviceId()}";
    } else {
      mqttId = "Android/${await getDeviceId()}";
    }

    return mqttId;
  }

  Future<String> getAppTopic() async {
    final mqId = await getMqttId();
    return "$MobileTopicStart/$mqId";
  }

  String getKaraokeTopic() => config != null
      ? "$KaraokeTopicStart/${config.model}/${config.topic}"
      : null;

  Future<String> getDeviceId() async {
    final pref = await SharedPreferences.getInstance();
    var uuid = pref.getString(MagicUUID);

    if (uuid?.isEmpty ?? true) {
      uuid = Uuid().v4();
      pref.setString(MagicUUID, uuid);
    }

    return uuid;
  }

  void sendKey(KeyButton key) {
    //lol botton
    final jObj = {"KEYBOTTON": _KeyButtonCommand[key]};

    _sendString(getKaraokeTopic(), "KEY${json.encode(jObj)}");
  }

  void sendCommand(String command) {
    final jObj = {
      "COMMAND": command,
      "INTVAL": 0,
      "NAME": " ",
      "STRVAL": " ",
    };

    _sendString(getKaraokeTopic(), "COM${json.encode(jObj)}");
  }

  //COM{"COMMAND":"REQ_RESERVLIST","INTVAL":0,"NAME":" ","STRVAL":" "}
  Future<List<Song>> getReservationList() async {
    //Tells the karaoke who to send data to
    await _sendWWO();

    final comp = Completer<List<Song>>();
    _reservationRequests.add(comp);

    sendCommand("REQ_RESERVLIST");

    return await comp.future.timeout(Duration(seconds: 30), onTimeout: () {
      _reservationRequests.remove(comp);
      throw "Timeout";
    });
  }
}

enum KeyButton { Stop, Play }

const _KeyButtonCommand = {
  KeyButton.Stop: "STOP",
  KeyButton.Play: "PLAY",
};

/*
how the app makes the device id UUID, we will just make one and save it for later
this requires app permissions which are not worth requesting (READ_PRIVILEGED_PHONE_STATE)
private String GetDeviceUUID(Context mContext) {
        TelephonyManager tm = (TelephonyManager) mContext.getSystemService("phone");
        String tmDevice = "" + tm.getDeviceId();
        String tmSerial = "" + tm.getSimSerialNumber();
        String androidId = "" + Settings.Secure.getString(getContentResolver(), "android_id");
        String deviceId = new UUID((long) androidId.hashCode(), (((long) tmDevice.hashCode()) << 32) | ((long) tmSerial.hashCode())).toString();
        //String uuid = new UUID((long) androidId.hashCode(), (((long) tmDevice.hashCode()) << 32) | ((long) wmac.hashCode())).toString();
        //String uuid2 = new UUID((long) androidId.hashCode(), (((long) wmac.hashCode()) << 32) | ((long) tmSerial.hashCode())).toString();
        return deviceId;
    }
*/
