import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:magic_master/mb_search.dart';

const MusicBrainzApi = "https://musicbrainz.org/ws/2";
const MusicBrainzUserAgent = "MagicSing/1.0 (magic.sing@v0l.io)";
const MusicBrainzUA = {"User-Agent": MusicBrainzUserAgent};
const MusicBrainzConcurrentRequests = 2;

class MusicBrainz {
  static MusicBrainz _instance = MusicBrainz();
  static MusicBrainz get instance => _instance;

  //https://musicbrainz.org/ws/2/recording?query=%22super%20bass%22%20AND%20artist:nicki%20minaj%20ft%20ester%20dean&fmt=json&limit=1
  //https://coverartarchive.org/release/{mbid}/front

  Queue<Completer> _queue = Queue<Completer>();
  int _running = 0;

  MusicBrainz() {
    Timer.periodic(Duration(seconds: 1), (t) {
      if (_queue.isNotEmpty && _running < MusicBrainzConcurrentRequests) {
        final comp = _queue.removeFirst();
        comp.complete(true);
      }
    });
  }

  Future<RecordingSearch> searchRecording(String song, String artist) async {
    final cm = DefaultCacheManager();

    final query = "\"$song\" AND artist:$artist";
    final url =
        "$MusicBrainzApi/recording?query=${Uri.encodeFull(query)}&fmt=json&limit=1";

    String jsonData;
    // Skip rate limit if we already have the file cached
    final cachedFile = await cm.getFileFromCache(url);
    if (cachedFile == null) {
      // Queue and wait for timer to let us run
      final comp = Completer<bool>();
      _queue.add(comp);
      await comp.future;
      _running++;

      //print(url);
      final result = await cm.getSingleFile(url, headers: MusicBrainzUA);

      jsonData = await result?.readAsString();
    } else {
      jsonData = await cachedFile.file.readAsString();
    }
    if (jsonData?.isNotEmpty ?? false) {
      _running--;
      return RecordingSearch.fromJson(json.decode(jsonData));
    }

    _running--;
    return RecordingSearch();
  }

  String getCoverImage(String release) {
    final ret = "https://coverartarchive.org/release/$release/front-small";
    //print(ret);
    return ret;
  }
}
