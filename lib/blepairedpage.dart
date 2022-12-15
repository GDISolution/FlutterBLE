import 'package:flutter/material.dart';
import 'package:flutter_ble/connectpage.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

class BlePairedPage extends StatefulWidget {
  const BlePairedPage({Key? key}) : super(key: key);

  @override
  State<BlePairedPage> createState() => _BlePairedPageState();
}

class _BlePairedPageState extends State<BlePairedPage> {
  List<BluetoothDevice> bondedDevice = [];

  @override
  void initState() {
    super.initState();

    init();
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
      print('페어드기기 ==> ${bondedDevice[0].id.id}');
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
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
      onTap: () => {
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
                          builder: (context) => ConnectPage(device: d)),
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
                ),
              ],
            );
          },
        ),
      },
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
        title: Text("BLE Paried"),
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
