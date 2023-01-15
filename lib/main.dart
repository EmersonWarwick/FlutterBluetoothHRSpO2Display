//Copyright 2023 Emerson Warwick Limited

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:healthapp/reportpage.dart';

import 'bluetooth.dart';
import 'capturedatapage.dart';
import 'constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    FlutterBlue flutterBlue = FlutterBlue.instance;
    BluetoothConnectionService bts = BluetoothConnectionService.instance;

    return MaterialApp(
      title: TITLE,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => ReportPage(title: REPORTPAGETITLE, flutterBlue: flutterBlue, bluetoothConnectionService: bts),
        '/capture': (context) => CaptureDataPage(title: CAPTUREDATAPAGETITLE, flutterBlue: flutterBlue, bluetoothConnectionService: bts),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}