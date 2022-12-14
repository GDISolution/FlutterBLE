import 'package:flutter/material.dart';

import 'blepairedpage.dart';
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
      home: const FunList(),
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
            /*
            ListTile(
              title: Text(
                "01 Bluetooth LE Page",
                style: TextStyle(fontSize: 25),
              ),
              onTap:
                  () => /*Navigator.push(
                  context, MaterialPageRoute(builder: (_) => BlePage()))*/
                      {},
            ),
            ListTile(
              title: Text(
                "02 Bluetooth LE PairingPage",
                style: TextStyle(fontSize: 25),
              ),
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => PairingPage())),
            ),
            ListTile(
              title: Text(
                "03 BluetoothPage",
                style: TextStyle(fontSize: 25),
              ),
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => BluetoothPage())),
            ),
            ListTile(
              title: Text(
                "04 Ble Paired Page",
                style: TextStyle(fontSize: 25),
              ),
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => BlePairedPage())),
            ),
            ListTile(
              title: Text(
                "04 Ble Paired Page",
                style: TextStyle(fontSize: 25),
              ),
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => BlePairedPage())),
            ),*/
            ListTile(
              title: Text(
                "01 ????????? & ??????",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text('PairingPage'),
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => PairingPage())),
            ),
            ListTile(
              title: Text(
                "02 ????????? ??????",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text('BlePairedPage'),
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => BlePairedPage())),
            ),
          ],
        ),
      ),
    );
  }
}
