import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:magic_master/broker.dart';
import 'package:magic_master/mb.dart';
import 'package:magic_master/mb_search.dart';
import 'package:magic_master/song_manager.dart';
import 'package:recase/recase.dart';

class SongListSearch extends StatefulWidget {
  final SongManager songManager;

  SongListSearch({
    this.songManager,
  });

  @override
  State<StatefulWidget> createState() => _SongListSearch();
}

class _SongListSearch extends State<SongListSearch> {
  final StreamController _songSearchStream = StreamController<List<Song>>();
  String _lastSearch;
  StreamSubscription _songManagerSub;

  @override
  void initState() {
    _songManagerSub =
        widget.songManager.songManagerState.stream.listen((v) async {
      //Reload search results
      if (v == SongManagerState.SortingUpdated) {
        _songSearchStream.add(<Song>[]);
        final res = await widget.songManager.searchSongs(_lastSearch);
        _songSearchStream.add(res);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _songManagerSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 10,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Search",
                    ),
                    onSubmitted: (search) async {
                      _songSearchStream.add(<Song>[]);
                      _lastSearch = search;
                      final res = await widget.songManager.searchSongs(search);
                      _songSearchStream.add(res);
                    },
                  ),
                ),

                ///Sorting options
                ///
                Builder(
                  builder: (context) {
                    final theme = Theme.of(context);
                    return IconButton(
                      icon: Icon(Icons.sort),
                      onPressed: () async {
                        final RenderBox ro = context.findRenderObject();
                        final RenderBox overlay =
                            Overlay.of(context).context.findRenderObject();
                        final RelativeRect position = RelativeRect.fromRect(
                          Rect.fromPoints(
                            ro.localToGlobal(ro.size.bottomRight(Offset.zero),
                                ancestor: overlay),
                            ro.localToGlobal(ro.size.bottomRight(Offset.zero),
                                ancestor: overlay),
                          ),
                          Offset.zero & overlay.size,
                        );

                        final selectedStyle = (SongManagerSortBy v) {
                          if (widget.songManager.sort.by == v) {
                            return theme.textTheme.subhead.merge(
                              TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          } else {
                            return null;
                          }
                        };

                        final newSort = await showMenu<SongManagerSort>(
                          context: context,
                          position: position,
                          items: [
                            PopupMenuItem(
                              textStyle: selectedStyle(SongManagerSortBy.Song),
                              value: SongManagerSort(SongManagerSortBy.Song,
                                  SongManagerSortOrder.Asc),
                              child: Text("Song Name"),
                            ),
                            PopupMenuItem(
                              textStyle:
                                  selectedStyle(SongManagerSortBy.Artist),
                              value: SongManagerSort(SongManagerSortBy.Artist,
                                  SongManagerSortOrder.Asc),
                              child: Text("Artist Name"),
                            ),
                            PopupMenuItem(
                              textStyle: selectedStyle(SongManagerSortBy.New),
                              value: SongManagerSort(SongManagerSortBy.New,
                                  SongManagerSortOrder.Asc),
                              child: Text("New Songs"),
                            ),
                            PopupMenuItem(
                              textStyle: selectedStyle(SongManagerSortBy.Hit),
                              value: SongManagerSort(SongManagerSortBy.Hit,
                                  SongManagerSortOrder.Asc),
                              child: Text("Hit Songs"),
                            ),
                            PopupMenuItem(
                              textStyle: selectedStyle(SongManagerSortBy.Best),
                              value: SongManagerSort(SongManagerSortBy.Best,
                                  SongManagerSortOrder.Asc),
                              child: Text("Popular Songs"),
                            ),
                          ],
                        );

                        widget.songManager.setSorting(newSort);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Song>>(
              stream: _songSearchStream.stream,
              builder: (context, state) {
                if (state.hasData) {
                  return ListView(
                    children: <Widget>[
                      ...state.data.map(
                        (a) {
                          return Card(
                            child: ListTile(
                              title: Text(ReCase(a.title).titleCase),
                              subtitle: Text(ReCase(a.artist).titleCase),
                              leading: FutureBuilder<RecordingSearch>(
                                key: Key("${a.number}"),
                                future: () async {
                                  final result = await MusicBrainz.instance
                                      .searchRecording(a.title, a.artist);

                                  return result;
                                }(),
                                builder: (context, state) {
                                  if (state.hasData) {
                                    final id = () {
                                      // fucking first doesnt do emply list check
                                      final rec = state.data?.recordings;
                                      if ((rec?.length ?? 0) > 0) {
                                        final rel = rec?.first?.releases;
                                        if ((rel?.length ?? 0) > 0) {
                                          return rel?.first?.id;
                                        }
                                      }
                                      return null;
                                    }();
                                    if (id?.isNotEmpty ?? false) {
                                      return AspectRatio(
                                        aspectRatio: 1,
                                        child: CachedNetworkImage(
                                          fit: BoxFit.contain,
                                          imageUrl: MusicBrainz.instance
                                              .getCoverImage(id),
                                          errorWidget: (context, url, err) =>
                                              Placeholder(),
                                        ),
                                      );
                                    }
                                    return Placeholder();
                                  }
                                  return CircularProgressIndicator();
                                },
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () {
                                      Broker.instance.reserveSong(a);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.play_arrow),
                                    onPressed: () {
                                      Broker.instance.playSong(a);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                } else {
                  return SizedBox.shrink();
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
