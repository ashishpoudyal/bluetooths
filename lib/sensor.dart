import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:percent_indicator/percent_indicator.dart';

class DeviceScreen extends StatefulWidget {
  final BluetoothDevice device;

  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  late Stream<List<int>> listStream;
  late bool isReady;
  late BluetoothCharacteristic c;
  int sp = 0;
  int hr = 0;
  int sp1 = 0;
  int hr1 = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isReady = false;
    discoverService();
    Timer.periodic(Duration(seconds: 1), (timer) {
      discoverService();
    });
  }

  discoverService() async {
    List<BluetoothService> services = await widget.device.discoverServices();
    for (int i = 1; i < 50; i++) {
      for (var service in services) {
        if (service.uuid.toString() == "14839ac4-7d7e-415c-9a42-167340cf2339") {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toUpperCase() ==
                "8B00ACE7-EB0B-49B0-BBE9-9AEE0A26E1A3") {
              c = characteristic;
            }
            if (characteristic.uuid.toString().toUpperCase() ==
                "0734594A-A8E7-4B1A-A6B1-CD5243059A57") {
              await characteristic.setNotifyValue(true);
              listStream = characteristic.value;
              setState(() {
                isReady = true;
              });
            }
            await c.write([
              0xaa,
              0x17,
              0xe8,
              0x00,
              0x00,
              0x00,
              0x00,
              0x1b,
            ]);
            // await Future.delayed(const Duration(seconds: 5));
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SPO2 sensor'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
              child: !isReady
                  ? Center(
                      child: Text("waiting"),
                    )
                  : Column(
                      children: [
                        // Center(
                        //   child: TextButton(
                        //     child: Text("reload"),
                        //     onPressed: () {
                        //
                        //         discoverService();
                        //
                        //     },
                        //   ),
                        // ),
                        Container(
                          child: StreamBuilder<List<int>>(
                            stream: listStream,
                            builder: (BuildContext context,
                                AsyncSnapshot<List<int>> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.active) {
                                if (snapshot.data?.length == 20) {
                                  interpreteReceivedData(snapshot.data);

                                  sp = (snapshot.data?.elementAt(7))!;
                                  hr = (snapshot.data?.elementAt(8))!;
                                  if (sp < 100) {
                                    sp1 = sp;
                                  } else {
                                    sp1 = 0;
                                  }
                                  if (hr < 150) {
                                    hr1 = hr;
                                  } else {
                                    hr1 = 0;
                                  }
                                }

                                return Visibility(
                                  visible: false,
                                  child: Column(
                                    children: [
                                      Text(sp.toString()),
                                      Text(hr.toString()),
                                    ],
                                  ),
                                );
                              } else {
                                return SizedBox();
                              }
                              //your code goes here
                            },
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(15, 40, 15, 10),
                          child: Column(
                            children: [
                              // Text(sp.toString()),
                              // SizedBox(),
                              // Text(hr.toString()),

                              CircularPercentIndicator(
                                radius: 150.0,
                                lineWidth: 10.0,
                                // animation: true,
                                percent: ((sp1.toDouble()) / 100),
                                center: Text(
                                  "$sp1" "%",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0),
                                ),
                                footer: const Text(
                                  "Oxygen saturation (SpO2)",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17.0),
                                ),
                                circularStrokeCap: CircularStrokeCap.round,
                                progressColor: Colors.green,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 25,
                              ),
                              CircularPercentIndicator(
                                radius: 150.0,
                                lineWidth: 10.0,
                                // animation: true,
                                percent: ((hr1.toDouble()) / 150.0),
                                center: Text(
                                  "$hr1" "ﮩ٨ـ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0),
                                ),
                                footer: const Text(
                                  "Heart Rate",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17.0),
                                ),
                                circularStrokeCap: CircularStrokeCap.round,
                                progressColor: Colors.red,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
        ),
      ),
    );
  }

  void interpreteReceivedData(data) {
    print("abc");
    print("data:" + data.toString());
    // for (var item in data) {
    //   print("item value:" + item.toString());
    // }
  }
}
