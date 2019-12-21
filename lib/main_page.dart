import 'package:flutter/material.dart';
import 'package:magic_master/broker.dart';
import 'package:magic_master/const.dart';
import 'package:magic_master/karaoke_config.dart';
import 'package:magic_master/qr_scanner.dart';
import 'package:magic_master/reservation_list.dart';
import 'package:magic_master/song_list_cache.dart';
import 'package:magic_master/song_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState.openDrawer();
          },
        ),
        title: Text("MagicSing"),
        actions: <Widget>[
          ///QR scan button
          ///
          IconButton(
            onPressed: () async {
              final karaokeConfig = await Navigator.push<KaraokeConfig>(
                  context, QRScannerOverlay());
              //set karaoke data
              if (karaokeConfig != null) {
                final sp = await SharedPreferences.getInstance();
                await sp.setString(KaraokeInfo, karaokeConfig.toJson());

                await Broker.instance.start(karaokeConfig);
              }
            },
            icon: Icon(Icons.photo_camera),
          ),

          ///Rev list button
          ///
          Stack(
            children: [
              StreamBuilder(
                stream: Broker.instance.stateChange.stream,
                builder: (context, state) {
                  final c = Broker?.instance?.reservationCount ?? 0;
                  if (c > 0) {
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.lightGreen,
                      ),
                      padding: EdgeInsets.all(5),
                      child: Text("$c"),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
              IconButton(
                onPressed: () async {
                  await Navigator.pushNamed(context, ReservationList.routeName);
                },
                icon: Icon(Icons.list),
              ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          height: mq.size.height - mq.padding.top - mq.padding.bottom,
          margin: EdgeInsets.only(
            top: mq.padding.top,
            bottom: mq.padding.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildBrokerStatusCard(),
              Expanded(
                child: _buildRegionalDBList(theme),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          _buildLoadingWidget(),
          SongListCache(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.stop),
        onPressed: () {
          Broker.instance.sendKey(KeyButton.Stop);
        },
      ),
    );
  }

  Widget _buildBrokerStatusCard() {
    return StreamBuilder<BrokerState>(
      stream: Broker.instance.stateChange.stream,
      builder: (context, state) {
        final isConnected = Broker.instance.isConnected;
        return Card(
          child: ListTile(
            title: Text("Broker Status"),
            subtitle: Text(
              isConnected ? "Connected" : "Disconnected",
              style: TextStyle(
                color: isConnected ? Colors.lightGreen : Colors.red,
              ),
            ),
            trailing: Icon(
              isConnected ? Icons.check_circle : Icons.error_outline,
              color: isConnected ? Colors.lightGreen : Colors.red,
              size: 30,
            ),
          ),
        );
      },
    );
  }

  Widget _buildRegionalDBList(ThemeData theme) {
    return StreamBuilder<SongManagerState>(
      stream: SongManager.instance.songManagerState.stream,
      builder: (context, state) {
        return Card(
          child: ListView(
            children: <Widget>[
              ListTile(
                title: Text("Regional song list"),
              ),
              FutureBuilder<List<String>>(
                future: SongManager.instance.getFilterDBList(),
                builder: (context, state) {
                  if (state.hasData) {
                    final filters = state.data;
                    return Column(
                      children: <Widget>[
                        ...SongManager.instance.getDatabases().entries.map(
                          (a) {
                            return ListTile(
                              title: Text(
                                a.value,
                                overflow: TextOverflow.fade,
                              ),
                              leading: Checkbox(
                                value: filters.contains(a.key),
                                onChanged: (v) async {
                                  await SongManager.instance
                                      .toggleDBFilter(a.key);
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingWidget() {
    return StreamBuilder<SongManagerState>(
      stream: SongManager.instance.songManagerState.stream,
      builder: (context, state) {
        final loading = state.hasData &&
            (state.data == SongManagerState.Loading ||
                state.data == SongManagerState.Searching);
        return LinearProgressIndicator(
          value: loading ? null : 0,
        );
      },
    );
  }
}
