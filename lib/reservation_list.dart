import 'package:flutter/material.dart';
import 'package:magic_master/broker.dart';
import 'package:magic_master/song_manager.dart';
import 'package:recase/recase.dart';

class ReservationList extends StatefulWidget {
  static String get routeName => "/reservation-list";

  @override
  State<StatefulWidget> createState() => _ReservationList();
}

class _ReservationList extends State<ReservationList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reservation List"),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: FutureBuilder<List<Song>>(
                key: UniqueKey(),
                future: () async {
                  final res = await Broker.instance.getReservationList();
                  return res;
                }(),
                builder: (context, state) {
                  if (state.hasData) {
                    return ListView(
                      children: <Widget>[
                        ...state.data.map((a) {
                          return Card(
                            child: ListTile(
                              title: Text(ReCase(a.title).titleCase),
                              subtitle: Text(ReCase(a.artist).titleCase),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.delete,
                                ),
                                onPressed: () {
                                  setState(() {
                                    Broker.instance.removeReservedSong(a);
                                  });
                                },
                              ),
                            ),
                          );
                        })
                      ],
                    );
                  } else if (state.hasError) {
                    print(state.error);
                    return Center(
                      child: Column(children: [
                        Icon(
                          Icons.error,
                          color: Colors.red,
                          size: 50,
                        ),
                        Text(state.error.toString()),
                      ]),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
