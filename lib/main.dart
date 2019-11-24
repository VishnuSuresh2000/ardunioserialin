import 'dart:typed_data';

import 'package:ardunioserialin/responsive.dart';
import 'package:flutter/material.dart';
import 'package:oscilloscope/oscilloscope.dart';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String isan;
  String out;
  String outin;
  UsbPort port;
  List inputset = [];
  List dataSetIn = <double>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: Responsive.responsiveHeight(context, 150),
            ),
            Text("Usb Connected Device \n $isan"),
            SizedBox(
              height: Responsive.responsiveHeight(context, 30),
            ),
            RaisedButton(
              child: Text("Usb Device Connect"),
              onPressed: () {
                usbDetect();
              },
            ),
            SizedBox(
              height: Responsive.responsiveHeight(context, 50),
            ),
            Text("Ardunio final output : $outin"),
            SizedBox(
              height: Responsive.responsiveHeight(context, 30),
            ),
            // Container(
            //   height: 150,
            //   child: ListView.builder(
            //     itemCount: inputset.length,
            //     itemBuilder: (BuildContext context, int index) {
            //       return ListTile(
            //         title: Text("the vale is : ${inputset[index]} "),
            //       );
            //     },
            //   ),
            // )
            Container(
              height: Responsive.responsiveHeight(context, 350),
              child: Oscilloscope(
                dataSet: dataSetIn,
                showYAxis: true,
                backgroundColor: Colors.black,
                traceColor: Colors.yellow,
                yAxisMax: 10.0,
                yAxisMin: -10.0,
                padding: 20,
              ),
            )
          ],
        ),
      ),
    );
  }

  void usbDetect() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    print(devices);
    setState(() {
      isan = devices.toString();
    });
    UsbPort port;
    if (devices.length == 0) {
      return;
    }
    port = await devices[0].create();

    bool openResult = await port.open();
    if (!openResult) {
      print("Failed to open");
      setState(() {
        out = "Failed to open";
      });
      return;
    }

    await port.setDTR(true);
    await port.setRTS(true);

    port.setPortParameters(
        9600, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    Transaction<String> transaction = Transaction.stringTerminated(
        port.inputStream, Uint8List.fromList([13, 10]));
    transaction.stream.listen((String data) {
      print(data);
      setState(() {
        outin = data;
        inputset.add(data);
        dataSetIn.add(double.parse(data) ?? "0");
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    port.close();
  }
}
