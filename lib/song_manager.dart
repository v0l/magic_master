import 'dart:async';
import 'dart:convert';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:magic_master/const.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

enum SongManagerState {
  Ready,
  Searching,
  Loading,
  FiltersUpdated,
  SortingUpdated
}

enum SongManagerSortBy {
  Song,
  Artist,
  New,
  Best,
  Hit,
}

enum SongManagerSortOrder {
  Asc,
  Desc,
}

class SongManagerSort {
  final SongManagerSortBy by;
  final SongManagerSortOrder order;

  const SongManagerSort(this.by, this.order);
}

class SongManager {
  static SongManager _instance = SongManager();
  static SongManager get instance => _instance;

  final StreamController songManagerState =
      StreamController<SongManagerState>.broadcast();

  /// <name> - <filepath>
  Map<String, SongDB> databases;
  SongManagerSort _sort;

  SongManagerSort get sort => _sort;

  void setSorting(SongManagerSort s) {
    if (s != null) {
      _sort = s;
      songManagerState.add(SongManagerState.SortingUpdated);
    }
  }

  SongManager({this.databases}) {
    _sort = SongManagerSort(SongManagerSortBy.Song, SongManagerSortOrder.Asc);
    songManagerState.stream.listen((value) {
      print(value.toString());
    });
  }

  Future<void> loadManager() async {
    if (databases == null) {
      songManagerState.add(SongManagerState.Loading);
      final db = await SongDB.loadAll();
      if (db == null) {
        throw "Failed to load DB list";
      }

      databases = db;
      songManagerState.add(SongManagerState.Ready);
    }
  }

  Future<List<Song>> searchSongs(String search) async {
    songManagerState.add(SongManagerState.Searching);
    final ret = Map<int, Song>();

    final filter = await getFilterDBList();
    for (var db in databases.entries.where((a) => filter.contains(a.key))) {
      final dbConn = db.value.database;
      try {
        final results = await dbConn.rawQuery(
            db.value.hasNote ? SongSearch : SongSearchNoNotes,
            [db.key, "%$search%"]);
        for (var song in results.map((a) => Song.fromRow(a, db.value))) {
          if (!ret.containsKey(song.number)) {
            ret[song.number] = song;
          }
        }
      } catch (ex) {
        print("Error on ${db.key}: $ex");
      }
    }

    final retList = ret.values.toList();
    retList.sort((a, b) {
      switch (_sort.by) {
        case SongManagerSortBy.Song:
          return a.title.compareTo(b.title);
        case SongManagerSortBy.Artist:
          return a.artist.compareTo(b.artist);
        case SongManagerSortBy.New:
          return a.newSong.compareTo(b.newSong);
        case SongManagerSortBy.Best:
          return a.bestSong.compareTo(b.bestSong);
        case SongManagerSortBy.Hit:
          return a.hitSong.compareTo(b.hitSong);
      }
      return 0;
    });
    songManagerState.add(SongManagerState.Ready);
    return retList;
  }

  Map<String, String> getDatabases() {
    if (databases == null) {
      return Map<String, String>();
    }
    return Map<String, String>.fromEntries(databases.keys
        .where((a) =>
            !HymDB.contains(a) &&
            DBNames.containsKey(a) &&
            (DBNames[a]?.isNotEmpty ?? false))
        .map((a) => MapEntry(a, DBNames[a])));
  }

  Future<List<String>> getFilterDBList() async {
    final pref = await SharedPreferences.getInstance();

    final filters = pref.getStringList(DBFilter);
    if (filters == null) {
      await pref.setStringList(DBFilter, DefaultDBFilter);
      return DefaultDBFilter;
    }

    return filters;
  }

  Future<bool> toggleDBFilter(String db) async {
    final pref = await SharedPreferences.getInstance();

    var ret = false;
    final filters = await getFilterDBList();
    if (filters.contains(db)) {
      filters.remove(db);
      ret = false;
    } else {
      filters.add(db);
      ret = true;
    }
    await pref.setStringList(DBFilter, filters);

    songManagerState.add(SongManagerState.FiltersUpdated);

    return ret;
  }
}

class Song {
  final int number;
  final String title;
  final String artist;
  final int songType;
  final int nation;
  final int newSong;
  final int hitSong;
  final int bestSong;
  final int notes;
  final String db;

  Song({
    this.number,
    this.title,
    this.artist,
    this.songType,
    this.nation,
    this.newSong,
    this.hitSong,
    this.bestSong,
    this.notes,
    this.db,
  });

  static Song fromRow(Map<String, dynamic> data, SongDB inDB) {
    return Song(
      number: data["number"] as int,
      title: data["title"] as String,
      artist: data["artist"] as String,
      songType: int.tryParse(data["song_type"] as String),
      nation: int.tryParse(data["nation"] as String),
      newSong: data["newsong"] as int,
      hitSong: data["hitsong"] as int,
      bestSong: data["hitsong"] as int,
      notes: data["notes"] as int,
      db: data["db"] as String,
    );
  }

  String toSongRequestJson() {
    return json.encode({
      "SONGNUMBER": number,
      "SONGNATION": nation,
      "SONGTYPE": songType,
      "ACCOUNTVALID": 1,
      "FORMAT": 0,
      "SONGTITLE": title.toUpperCase(),
      "SONGSINGER": artist.toUpperCase(),
    });
  }
}

/*
{
	"VERSION": 1253,
	"ARABSONG": 2122752,
	"AST19K": 2361344,
	"BGDSONG": 1895424,
	"CHIHYMN": 342016,
	"CHISONG": 4485120,
	"ESPSONG": 2288640,
	"FINSONG": 1790976,
	"GERSONG": 1904640,
	"IDNSONG": 2010112,
	"INDSONG": 2440192,
	"JPSONG": 4945920,
	"KORBUL": 76800,
	"KORHYMN": 492544,
	"KORKID": 171008,
	"KORLSONG": 7638016,
	"KORSONG": 7646208,
	"MNGSONG": 1768448,
	"POPSONG": 1800192,
	"PUPPY": 33792,
	"RAFSONG": 52224,
	"RUSSONG": 3136512,
	"THASONG": 3430400,
	"TURSONG": 1914880,
	"VIETSONG": 3933184
}
*/

class SongDB {
  final String name;
  final int version;

  final bool hasNote;

  final Database _db;

  SongDB({this.name, this.version, this.hasNote = true, Database db})
      : _db = db;

  Database get database => _db;

  static Future<Map<String, int>> fetchList() async {
    final cache = await DefaultCacheManager().getSingleFile(
        "http://dnt.magicsing.xyz/pds/streaming/DB/MagicsingKaraoke/DB.ver");

    final jd = await cache.readAsString();
    if (jd?.isNotEmpty ?? false) {
      final ret = Map<String, int>.from(json.decode(jd));
      ret.remove("VERSION");
      return ret;
    }
    return null;
  }

  static Future<Map<String, SongDB>> loadAll() async {
    final ret = Map<String, SongDB>();

    final cache = DefaultCacheManager();
    final dbs = await fetchList();
    for (var db in dbs.entries) {
      final xdb = await cache.getSingleFile(
          "http://dnt.magicsing.xyz/pds/streaming/DB/MagicsingKaraoke/${db.key}.DB");
      if (!ret.containsKey(db) && xdb != null) {
        var hasNote = true;
        final dbConn = await openDatabase(xdb.path);
        try {
          final results =
              await dbConn.rawQuery("PRAGMA table_info('songlist')");
          hasNote = results.any((a) => a["name"] as String == "notes");
        } catch (ex) {
          print("Error on table_info ${db.key}: $ex");
        }
        ret[db.key] = SongDB(
            name: db.key, version: db.value, hasNote: hasNote, db: dbConn);
      }
    }

    return ret;
  }
}
