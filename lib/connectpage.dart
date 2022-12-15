import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ConnectPage extends StatefulWidget {
  const ConnectPage({super.key, required this.device});

  final BluetoothDevice device;

  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  FlutterBluePlus fBle = FlutterBluePlus.instance;

  String state = 'Connecting';
  String buttonText = 'Disconnect';

  BluetoothDeviceState deviceState = BluetoothDeviceState.disconnected;

  StreamSubscription<BluetoothDeviceState>? _stateListener;

  List<BluetoothService> bluetoothService = [];

  List<int> notifyData = [];

  final _textController = TextEditingController();

  late FocusNode focusNode;

  String destUuids = '';
  String sendData = 'hello';
  String sampleUuid = '0000fff2-0000-1000-8000-00805f9b34fb';

  late BluetoothCharacteristic destBle;

  @override
  void initState() {
    super.initState();

    focusNode = FocusNode();

    _stateListener = widget.device.state.listen((event) {
      debugPrint('event: $event');

      if (deviceState == event) {
        return;
      }

      setBleConnectionState(event);
    });

    connect();
  }

  @override
  void dispose() {
    super.dispose();

    _stateListener?.cancel();

    focusNode.dispose();

    disconnect();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  ///연결 상태 갱신
  setBleConnectionState(BluetoothDeviceState event) {
    switch (event) {
      case BluetoothDeviceState.disconnected:
        state = 'Disconnected';
        buttonText = 'Connect';
        break;
      case BluetoothDeviceState.disconnecting:
        state = 'Disconnecting';
        break;
      case BluetoothDeviceState.connected:
        state = 'Connected';
        buttonText = 'Disconnect';
        break;
      case BluetoothDeviceState.connecting:
        state = "Connecting";
        break;
    }
    deviceState = event;
    setState(() {});
  }

  ///start connecting
  Future<bool> connect() async {
    Future<bool>? returnValue;
    setState(() {
      state = "Connecting";
    });

    await widget.device
        .connect(autoConnect: false)
        .timeout(Duration(milliseconds: 10000), onTimeout: () {
      returnValue = Future.value(false);
      debugPrint('timeout failed');

      setBleConnectionState(BluetoothDeviceState.disconnected);
    }).then((data) async {
      bluetoothService.clear();

      if (returnValue == null) {
        debugPrint('connection successful');
        List<BluetoothService> bleServices =
            await widget.device.discoverServices();
        setState(() {
          bluetoothService = bleServices;
        });

        for (BluetoothService service in bleServices) {
          print("Service UUID: ${service.uuid}");
          for (BluetoothCharacteristic c in service.characteristics) {
            if (c.properties.notify && c.descriptors.isNotEmpty) {}

            if (!c.isNotifying) {
              try {
                await c.setNotifyValue(true);
                c.value.listen((value) {
                  setState(() {
                    notifyData = value;
                  });

                  if (value.isNotEmpty) {
                    showToast('데이터 송신중...');
                  }
                });

                await Future.delayed(const Duration(milliseconds: 100));
              } catch (e) {
                print('Error ${c.uuid} $e');
              }
            }
          }
        }

        returnValue = Future.value(true);
      }
    });

    return returnValue ?? Future.value(false);
  }

  ///disconnecting
  void disconnect() {
    try {
      setState(() {
        state = 'Disconnecting';
      });
      widget.device.disconnect();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Widget serviceInfo(BluetoothService bs) {
    String name = '';
    String properties = '';
    String data = '';
    print('BluetoothService: ${bs.deviceId}');

    for (BluetoothCharacteristic c in bs.characteristics) {
      properties = '';
      name += '\t\t[characteristicUUID]\n \t${c.uuid}\n';

      if (c.properties.write) {
        if (c.uuid.toString() == sampleUuid) {
          destUuids = c.uuid.toString();
          destBle = c;
        }
        properties += 'Write';
      } else if (c.properties.read) {
        properties += 'Read';
      } else if (c.properties.notify) {
        if (notifyData.isNotEmpty) {
          data = notifyData[notifyData.length - 1].toInt().toString();
        }
        properties += 'Notify';
      } else {
        properties += 'Etc';
      }
      name += '\t\t\t\u25CF Properties: $properties\n';

      if (data.isNotEmpty) {
        name += '\t\t\t\t\t\t\u002D data: $data\n';
      }
    }

    return Text(name);
  }

  Future<void> writeData(BluetoothCharacteristic c, String data) async {
    await c.write(utf8.encode(data));
  }

  Future<List<int>> readData(BluetoothCharacteristic c) async {
    return Future.value(c.read());
  }

  void checkTextEmpty() {
    String txt;

    txt = _textController.text;

    if (txt.isEmpty) {
      showToast('데이터를 입력하세요');
    }
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.teal.withOpacity(0.5),
      textColor: Colors.black,
    );
  }

  Widget serviceUUID(BluetoothService bs) {
    String name = '[serviceUUID]';
    name += '\n${bs.uuid.toString()}';
    return Text(
      name,
      style: TextStyle(fontWeight: FontWeight.bold),
    );
  }

  Widget listItem(BluetoothService bs) {
    return ListTile(
      onTap: null,
      title: serviceUUID(bs),
      subtitle: serviceInfo(bs),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.device.name,
          style: TextStyle(fontSize: 18),
        ),
        backgroundColor: Colors.teal.withOpacity(0.5),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(state),
                OutlinedButton(
                    onPressed: () {
                      if (deviceState == BluetoothDeviceState.connected) {
                        disconnect();
                      } else if (deviceState ==
                          BluetoothDeviceState.disconnected) {
                        connect();
                      }
                    },
                    child: Text(buttonText)),
              ],
            ),
            Expanded(
              child: ListView.separated(
                  itemBuilder: (context, index) {
                    return listItem(bluetoothService[index]);
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider();
                  },
                  itemCount: bluetoothService.length),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey,
        onPressed: () {
          focusNode.requestFocus();
          showDialog(
              context: context,
              barrierDismissible: false,
              barrierColor: Colors.transparent,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Colors.indigoAccent,
                  title: Text(
                    '전송 데이터',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  content: TextField(
                    autofocus: true,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    cursorColor: Colors.white12,
                    controller: _textController,
                    onChanged: (value) {
                      setState(() {
                        sendData = value;
                        print('sendData => $sendData');
                      });
                    },
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        checkTextEmpty();
                        writeData(destBle, sendData);
                        print('Destination = $destUuids');

                        _textController.clear();
                        showToast("전송 완료!");
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        '전송',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _textController.clear();
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        '취소',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                );
              });
        },
        child: Icon(Icons.send),
      ),
    );
  }
}
