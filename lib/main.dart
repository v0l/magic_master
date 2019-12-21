import 'package:flutter/material.dart';
import 'package:magic_master/broker.dart';
import 'package:magic_master/main_page.dart';
import 'package:magic_master/reservation_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //try to auto connect to broker
  //dont wait for it, app will start next
  Broker.instance.startFromConfig();

  runApp(MagicSingApp());
}

class MagicSingApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MagicSing',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(),
      routes: {
        ReservationList.routeName: (ctx) => ReservationList(),
      },
    );
  }
}
