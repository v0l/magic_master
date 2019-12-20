import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:magic_master/song_list_search.dart';
import 'package:magic_master/song_manager.dart';

class SongListCache extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SongListCache();
}

class _SongListCache extends State<SongListCache> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SongManager>(
      future: () async {
        await SongManager.instance.loadManager();
        return SongManager.instance;
      }(),
      builder: (context, state) {
        if (state.hasData) {
          return SongListSearch(
            songManager: state.data,
          );
        } else if (state.hasError) {
          return Text(state.error?.toString() ?? "Uknown error..");
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}
