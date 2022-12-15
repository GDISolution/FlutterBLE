import 'package:flutter/material.dart';
import 'package:flutter_ble/connectpage.dart';
import 'package:flutter_ble/pairingpage.dart';
import 'package:flutter_ble/refernce/testpage.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'devicepage.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPage();
}

class _MainPage extends State<MainPage> with TickerProviderStateMixin {
  final FlutterBluePlus _fBle = FlutterBluePlus.instance;

  List<ScanResult> scanResults = [];
  List<BluetoothDevice> bondedDevices = [];

  int scanResult = 0;
  bool isScanning = false;

  late final AnimationController _animatedController = AnimationController(
    vsync: this,
    duration: Duration(seconds: 1),
  )..repeat(reverse: true);

  late final Animation<double> _animation =
      CurvedAnimation(parent: _animatedController, curve: Curves.easeInToLinear);

  @override
  void dispose() {
    _animatedController.dispose();

    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();

    scan();

    _fBle.isScanning.listen((event) async {
      isScanning = event;
      if (event) {
        // await Future.delayed(Duration(seconds: 4));
        setState(() {
          if (event) {
            getPairedDevice();
          }
        });
      }
    });
  }

  Future<List<BluetoothDevice>> getBondedDevices() async {
    return Future.value(FlutterBluePlus.instance.bondedDevices);
  }

  void scan() async {
    if (await Permission.bluetoothScan.request().isGranted) {}
    Map<Permission, PermissionStatus> status = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();

    if (!isScanning) {
      _fBle.startScan(timeout: Duration(seconds: 5));

      // showLoading();
      await Future.delayed(Duration(seconds: 5));
      hideLoading();

      scanResults.clear();

      _fBle.scanResults.listen((results) {
        for (var r in results) {
          if (r.device.name.contains('GDI') &&
              scanResults.indexWhere((element) => element == r) < 0) {
            if (bondedDevices.indexWhere((element) => element.id.id == r.device.id.id) > -1) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('알림'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[Text('${r.device.name}에 연결하시겠습니까?')],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () async {
                            gotoConnectPage(r.device);
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
                  });
            } else {
              Fluttertoast.showToast(
                  msg: 'No devices Paired',
                  toastLength: Toast.LENGTH_SHORT,
                  backgroundColor: Colors.teal.withOpacity(0.5),
                  textColor: Colors.white);
              scanResults.add(r);
            }
          }
        }
        setState(() {});
      });
    } else {
      _fBle.stopScan();
    }
  }

  void getPairedDevice() async {
    if (await Permission.bluetoothScan.request().isGranted) {}
    Map<Permission, PermissionStatus> status = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();

    getBondedDevices().then((value) {
      for (var element in value) {
        setState(() {
          bondedDevices.add(element);
        });
      }
      print('페어드 기기 ==> ${bondedDevices[0].name}');
      // gotoConnectPage(bondedDevices[0]);
    });
  }

  void gotoConnectPage(BluetoothDevice bleDevice) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => ConnectPage(device: bleDevice)));
  }

  void showLoading() {
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  void hideLoading() {
    // Navigator.of(context).pop();
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DevicePage(devices: scanResults),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: SizedBox(
            width: 90,
            height: 90,
            child: FloatingActionButton(
              onPressed: () {
                scan();
              },
              child: Icon(
                Icons.bluetooth_outlined,
                color: Colors.white,
                size: 45,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
