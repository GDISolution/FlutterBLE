import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:flutter_blue_plus/gen/flutterblueplus.pb.dart' as protos;

class BlePage extends StatefulWidget {
  const BlePage({super.key});

  @override
  State<BlePage> createState() => _BlePageState();
}

class _BlePageState extends State<BlePage> {
  List<BluetoothDevice> bondedDevice = [];
  static const MethodChannel _channel = MethodChannel('com.ble.flutter_ble');

  @override
  void initState() {
    super.initState();

    init();
  }

  // Future<List<BluetoothDevice>> get bondedDevices {
  //   return _channel
  //       .invokeMethod('getBondedDevices')
  //       .then((buffer) => protos.ConnectedDevicesResponse.fromBuffer(buffer))
  //       .then((d) => d.devices)
  //       .then((d) => d.map((e) => BluetoothDevice.fromProto(e)).toList());
  // }

  void init() async {
    if (await Permission.bluetoothScan.request().isGranted) {}
    Map<Permission, PermissionStatus> status = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
  }

  String getDeviceName(BluetoothDevice d) {
    return d.name;
  }

  Widget itemList(BluetoothDevice d) {
    return ListTile(
      title: Text(
        d.name,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        d.id.id,
      ),
      leading: Icon(Icons.devices),
      onTap: () => showToast(d.id.id),
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
