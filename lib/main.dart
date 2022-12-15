import 'package:flutter/material.dart';
import 'package:flutter_ble/refernce/testpage.dart';
import 'package:flutter_ble/temp/animatedpage.dart';

import 'blepairedpage.dart';
import 'mainpage.dart';
import 'pairingpage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainPage(),
    );
  }
}

class FunList extends StatelessWidget {
  const FunList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: Text("Flutter Example"),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            ListTile(
              title: Text(
                "01 페어링 & 연결",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text('PairingPage'),
              onTap: () =>
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PairingPage())),
            ),
            ListTile(
              title: Text(
                "02 페어드 기기",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text('BlePairedPage'),
              onTap: () =>
                  Navigator.push(context, MaterialPageRoute(builder: (_) => BlePairedPage())),
            ),
            ListTile(
              title: Text(
                "03 Flutter Flow",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text('TestPage'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MainPage())),
            ),
          ],
        ),
      ),
    );
  }
}
