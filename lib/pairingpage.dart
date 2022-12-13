import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'connectpage.dart';

class PairingPage extends StatefulWidget {
  const PairingPage({Key? key}) : super(key: key);

  @override
  State<PairingPage> createState() => _PairingPageState();
}

class _PairingPageState extends State<PairingPage> {
  bool isScanning = false;
  List<ScanResult> scanResult = [];

  List<BluetoothDevice> bondedDevice = [];
  bool bonded = false;

  final FlutterBluePlus _fBle = FlutterBluePlus.instance;

  static const MethodChannel _channel = MethodChannel('com.ble.flutter_ble');

  @override
  void initState() {
    super.initState();

    scan();

    // init();

    _fBle.isScanning.listen((event) {
      isScanning = event;
      setState(() {});
    });
  }

  Future<List<BluetoothDevice>> getBondedDevices() async {
    return Future.value(FlutterBluePlus.instance.bondedDevices);
  }

  void init() async {
    if (await Permission.bluetoothScan.request().isGranted) {}
    Map<Permission, PermissionStatus> status = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();

    getBondedDevices().then((value) {
      for (var element in value) {
        setState(() {
          bondedDevice.add(element);
        });
      }
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void scan() async {
    _fBle.connectedDevices.asStream().listen((event) {
      // print('paired device: $event');
    });

    if (await Permission.bluetoothScan.request().isGranted) {}
    Map<Permission, PermissionStatus> status = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();

    if (!isScanning) {
      _fBle.startScan(timeout: Duration(seconds: 5));

      openDialog();
      await Future.delayed(Duration(seconds: 5));
      closeDialog();

      _fBle.scanResults.listen((results) {
        for (var result in results) {
          if (scanResult.indexWhere((e) => e.device.id == result.device.id) <
              0) {
            scanResult.add(result);
          }
        }
        // scanResult = event;
        setState(() {});
      });
    } else {
      _fBle.stopScan();
    }
  }

  Future<void> pair(ScanResult r) async {
    if (Platform.isAndroid) {
      return await _channel.invokeMethod('pair', r.device.id.toString());
    }
  }

  String getDeviceName(ScanResult r) {
    String name;
    if (r.device.name.isEmpty) {
      name = "No Name";
    } else {
      name = r.device.name;
    }

    return name;
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

  void openDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  void closeDialog() {
    Navigator.of(context).pop();
  }

  Widget itemList(ScanResult r) {
    return ListTile(
      title: Text(
        getDeviceName(r),
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        r.device.id.id,
      ),
      leading: IconButton(
        icon: Icon(Icons.link),
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('알림'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[Text('해당 기기를 연결하시겠습니까?')],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ConnectPage(device: r.device)),
                      );
                      setState(() {
                        Navigator.pop(context);
                      });
                    },
                    child: Text('예'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('아니오'),
                  )
                ],
              );
            },
          );
        },
      ),
      onTap: () => {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('알림'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[Text('페어링 하시겠습니까?')],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    pair(r);
                  },
                  child: Text('예'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('아니오'),
                )
              ],
            );
          },
        ),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bluetooth LE"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: ListView.separated(
          itemBuilder: (context, index) {
            return itemList(scanResult[index]);
          },
          separatorBuilder: (BuildContext context, int index) {
            return Divider();
          },
          itemCount: scanResult.length,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          scan();
        },
        backgroundColor: Colors.grey,
        child: Icon(isScanning ? Icons.stop : Icons.bluetooth),
      ),
    );
  }
}
