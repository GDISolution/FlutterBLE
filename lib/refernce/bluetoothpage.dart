import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../connectpage.dart';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  bool isScanning = false;
  List<BluetoothDevice> bondedDevice = [];

  final FlutterBluetoothSerial _fBleSerial = FlutterBluetoothSerial.instance;

  static const MethodChannel _channel = MethodChannel('com.ble.flutter_ble');

  @override
  void initState() {
    super.initState();

    init();
    getBondedDevices();
  }

  Future<List<BluetoothDevice>> getBondedDevices() async {
    final List devices = await _channel.invokeMethod('getBondedDevices');
    setState(() {
      bondedDevice = devices.map((e) => BluetoothDevice.fromMap(e)).toList();
    });

    return devices.map((map) => BluetoothDevice.fromMap(map)).toList();
  }

  void init() async {
    if (await Permission.bluetoothScan.request().isGranted) {}
    Map<Permission, PermissionStatus> status = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
  }

  void connect() {}

  // void pairing(BluetoothDevice device) async {
  //   print('selected: ${device.address}');
  //
  //   try {
  //     BluetoothConnection connection =
  //         await BluetoothConnection.toAddress(device.address);
  //     showToast('Connecting...');
  //
  //     connection.input?.listen((event) {
  //       connection.output.add(event);
  //
  //       if (ascii.decode(event).contains('!')) {
  //         connection.finish();
  //         showToast('Disconnecting');
  //       }
  //     }).onDone(() {
  //       showToast('Disconnected by remote request');
  //     });
  //   } catch (exception) {
  //     print('exception occurred');
  //   }
  // }

  String getDeviceName(BluetoothDevice d) {
    return d.name!;
  }

  Widget itemList(BluetoothDevice d) {
    return ListTile(
      title: Text(
        d.name!,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        d.address,
      ),
      leading: Icon(Icons.devices),
      onTap: () => connect(),
    );
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.teal.withOpacity(0.3),
      textColor: Colors.black,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bluetooth"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: ListView.separated(
          itemBuilder: (context, index) {
            return itemList(bondedDevice[index]);
          },
          separatorBuilder: (BuildContext context, int index) {
            return Divider();
          },
          itemCount: bondedDevice.length,
        ),
      ),
    );
  }
}
