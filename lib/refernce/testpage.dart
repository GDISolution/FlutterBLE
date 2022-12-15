import 'package:flutter/material.dart';
import 'package:flutter_ble/connectpage.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final FlutterBluePlus _fBle = FlutterBluePlus.instance;
  final _scrollController = ScrollController();

  List<ScanResult> scanResults = [];

  bool isScanning = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      addScrollController();
    });

    scan();

    _fBle.isScanning.listen((event) {
      isScanning = event;
      setState(() {});
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void addScrollController() {
    if (_scrollController.offset ==
            _scrollController.position.minScrollExtent &&
        !_scrollController.position.outOfRange) {
      scan();
    }
  }

  void scan() async {
    if (await Permission.bluetoothScan.request().isGranted) {}
    Map<Permission, PermissionStatus> status = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();

    if (!isScanning) {
      _fBle.startScan(timeout: Duration(seconds: 5));

      showLoading();
      await Future.delayed(Duration(seconds: 5));
      hideLoading();

      _fBle.scanResults.listen((results) {
        for (var r in results) {
          // if (scanResults.indexWhere((e) => e.device.id == r.device.id) < 0 &&
          //     r.device.name.isNotEmpty) {
          //   scanResults.add(r);
          // }
          if (r.device.name == 'GDI') {
            scanResults.add(r);
          }
        }
        // scanResult = event;
        setState(() {});
        if (scanResults.isEmpty) {
          Fluttertoast.showToast(
            msg: 'No Devices detected',
            backgroundColor: Colors.teal.withOpacity(0.5),
            toastLength: Toast.LENGTH_SHORT,
          );
        }
      });
    } else {
      _fBle.stopScan();
    }
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
    Navigator.of(context).pop();
  }

  String getDeviceName(ScanResult result) {
    String deviceNm = '';
    if (result.device.name.isNotEmpty) {
      deviceNm = result.device.name;
    } else {
      deviceNm = 'No Name';
    }

    return deviceNm;
  }

  Widget scanItem(ScanResult result) {
    return ListTile(
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
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
                                ConnectPage(device: result.device)),
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
            });
      },
      leading: Icon(
        Icons.link,
      ),
      title: Text(
        getDeviceName(result),
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(result.device.id.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(
          'Bluetooth Connection',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
              alignment: AlignmentDirectional(-0.9, 0),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
                child: Text(
                  'Nearby Devices',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                itemBuilder: (context, index) {
                  return scanItem(scanResults[index]);
                },
                separatorBuilder: (context, index) => Divider(),
                itemCount: scanResults.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
