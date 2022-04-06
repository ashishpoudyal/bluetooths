import 'dart:convert';
import 'dart:math';

import 'package:bluetooth/sensor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'widgets.dart';

// late Stream<List<int>> listStream;
void main() {
  runApp(const FlutterBlueApp());
}

class FlutterBlueApp extends StatelessWidget {
  const FlutterBlueApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.lightBlue,
      home: StreamBuilder<BluetoothState>(
          stream: FlutterBlue.instance.state,
          initialData: BluetoothState.unknown,
          builder: (_, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              print("reached inside on state on");
              return FindDevicesScreen();
            }
            return BluetoothOffScreen(state: state);
            print("reached inside on state off");

            // return BluetoothOffScreen(
            //   state: state,
            // );
          }),
    );
  }
}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key? key, this.state}) : super(key: key);

  final BluetoothState? state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.',
              style: Theme.of(context)
                  .primaryTextTheme
                  .subtitle1
                  ?.copyWith(color: Colors.white),
            ),
            SizedBox(
              height: 50,
            ),
            Text(
              "©ASHISH",
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 10,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class FindDevicesScreen extends StatefulWidget {
  @override
  State<FindDevicesScreen> createState() => _FindDevicesScreenState();
}

class _FindDevicesScreenState extends State<FindDevicesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'find devices',
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              child: Column(
                children: [
                  Center(
                    child: Column(
                      children: [
                        StreamBuilder<List<BluetoothDevice>>(
                          stream: Stream.periodic(Duration(seconds: 2))
                              .asyncMap(
                                  (_) => FlutterBlue.instance.connectedDevices),
                          initialData: [],
                          builder: (c, snapshot) => Column(
                            children: snapshot.data!
                                .map((d) => ListTile(
                                      title: Text(
                                        d.name,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(d.id.toString()),
                                      trailing:
                                          StreamBuilder<BluetoothDeviceState>(
                                        stream: d.state,
                                        initialData:
                                            BluetoothDeviceState.disconnected,
                                        builder: (c, snapshot) {
                                          if (snapshot.data ==
                                              BluetoothDeviceState.connected) {
                                            return RaisedButton(
                                              child: Text('OPEN'),
                                              onPressed: () =>
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              DeviceScreen(
                                                                  device: d))),
                                            );
                                          }
                                          return Text(snapshot.data.toString());
                                        },
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                        StreamBuilder<List<ScanResult>>(
                            stream: FlutterBlue.instance.scanResults,
                            initialData: [],
                            builder: (c, snapshot) => Center(
                                  child: Column(
                                    children: snapshot.data!
                                        .map((r) => Center(
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .fromLTRB(
                                                        30, 15, 15, 15),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              r.device.name
                                                                  .toString(),
                                                              style: TextStyle(
                                                                fontSize: 20,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Text(r.device.id
                                                                .toString()),
                                                          ],
                                                        ),
                                                        Spacer(),
                                                        TextButton(
                                                            style: ButtonStyle(
                                                                backgroundColor:
                                                                    MaterialStateProperty.all<
                                                                            Color>(
                                                                        Colors
                                                                            .blue)),
                                                            onPressed: () {
                                                              r.device
                                                                  .connect();

                                                              print("value");
                                                              print(
                                                                  r.device.id);
                                                            },
                                                            child: Text(
                                                              "connect",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white),
                                                            )),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.refresh_outlined,
        ),
        onPressed: () async {
          print("reached on refresh");
          FlutterBlue.instance.startScan(timeout: Duration(seconds: 4));
        },
      ),
    );
  }
}

// class DeviceScreen extends StatefulWidget {
//   DeviceScreen({
//     Key? key,
//     required this.device,
//   }) : super(key: key);
//   final BluetoothDevice device;
//
//   @override
//   State<DeviceScreen> createState() => _DeviceScreenState();
// }
//
// class _DeviceScreenState extends State<DeviceScreen> {
//   late bool isReady;
//
//   late Stream<List<int>> listStream;
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     isReady = false;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             StreamBuilder<bool>(
//               stream: widget.device.isDiscoveringServices,
//               initialData: false,
//               builder: (c, snapshot) {
//                 return IconButton(
//                     onPressed: () async {
//                       BluetoothCharacteristic c;
//
//                       List<BluetoothService> services =
//                           await widget.device.discoverServices();
//                       services.forEach((service) async {
//                         // print("here is service" + service.toString());
//
//                         if (service.uuid.toString() ==
//                             "14839ac4-7d7e-415c-9a42-167340cf2339") {
//                           service.characteristics
//                               .forEach((characteristic) async {
//                             if (characteristic.uuid.toString().toUpperCase() ==
//                                 "8B00ACE7-EB0B-49B0-BBE9-9AEE0A26E1A3") {
//                               c = characteristic;
//                               c.write([
//                                 0xaa,
//                                 0x14,
//                                 0xeb,
//                                 0x00,
//                                 0x00,
//                                 0x00,
//                                 0x00,
//                                 0xc6
//                               ]);
//                             }
//
//                             if (characteristic.uuid.toString().toUpperCase() ==
//                                 "0734594A-A8E7-4B1A-A6B1-CD5243059A57") {
//                               print("inside read");
//
//                               await characteristic.setNotifyValue(true);
//                               listStream = characteristic.value;
//                               setState(() {
//                                 isReady = true;
//                               });
//
//                               // List ne = characteristic.value.toList() as List;
//                               // print("ne value"+ne.toString());
//                             }
//                           });
//                         }
//                       });
//
//                       // device.discoverServices();
//                     },
//                     icon: Icon(Icons.refresh));
//               },
//             ),
//             Container(
//               child: !isReady
//                   ? Text("waiting")
//                   : StreamBuilder<List<int>>(
//                       stream: listStream,
//                       builder: (BuildContext context,
//                           AsyncSnapshot<List<int>> snapshot) {
//                         print("i am inside stream builder");
//                         if (snapshot.connectionState ==
//                             ConnectionState.active) {
//                           interpreteReceivedData(snapshot.data);
//                           return Text("we are finding data+" +
//                               snapshot.data.toString());
//                         } else {
//                           return SizedBox();
//                         }
//                       }),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget build1(BuildContext context) {
//     return Center(
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text('Optical Dust Sensor'),
//         ),
//         body: Container(
//             child: !isReady
//                 ? Center(
//               child: Text("waiting"),
//             )
//                 : Container(
//               child: StreamBuilder<List<int>>(
//                 stream: listStream,
//                 builder: (BuildContext context,
//                     AsyncSnapshot<List<int>> snapshot) {
//                   if (snapshot.connectionState ==
//                       ConnectionState.active) {
//                     interpreteReceivedData(snapshot.data);
//                     return Text("we are finding data+" +
//                         snapshot.data.toString());
//                   } else {
//                     return SizedBox();
//                   }
//                 },
//               ),
//             )),
//       ),
//     );
//   }
//
//   void interpreteReceivedData(data) {
//     print("abc");
//     print("data:" + data.toString());
//     for (var item in data) {
//       print("item value:" + item.toString());
//     }
//   }
// }
