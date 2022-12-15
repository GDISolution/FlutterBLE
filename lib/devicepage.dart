import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'connectpage.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({super.key, required this.devices});

  final List<ScanResult> devices;

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  String deviceName = '';
  int deviceListLength = 0;

  @override
  void initState() {
    super.initState();

    if (deviceListLength > 0) {
      print('이게 잘 될까 ==> ${widget.devices[0].device.name}');
      deviceName = widget.devices[0].device.name;
      deviceListLength = widget.devices.length;
    } else {
      Fluttertoast.showToast(
        msg: 'No Devices detected',
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.teal,
      );
    }
  }

  Widget itemList(ScanResult r) {
    return ListTile(
      title: Text(
        r.device.name,
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
                        MaterialPageRoute(builder: (context) => ConnectPage(device: r.device)),
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
    );
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                // controller: _scrollController,
                itemBuilder: (context, index) {
                  return itemList(widget.devices[index]);
                },
                separatorBuilder: (context, index) => Divider(),
                itemCount: deviceListLength,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
