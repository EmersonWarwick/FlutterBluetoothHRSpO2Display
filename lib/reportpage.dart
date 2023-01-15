//Copyright 2023 Emerson Warwick Limited

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'bluetooth.dart';
import 'capturedatapage.dart';
import 'constants.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({
    Key? key,
    required this.title,
    required this.flutterBlue,
    required this.bluetoothConnectionService,
  }) : super(key: key);

  final String title;
  final FlutterBlue flutterBlue;
  final BluetoothConnectionService bluetoothConnectionService;

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late FlutterBlue _flutterBlue;
  late BluetoothConnectionService _bts;

  @override
  void initState() {
    super.initState();
    _flutterBlue = widget.flutterBlue;
    _bts = widget.bluetoothConnectionService;

    WidgetsBinding.instance
        ?.addPostFrameCallback((timeStamp) => runBluetoothSetup(context));
  }

  Future<void> runBluetoothSetup(BuildContext context) async {
    _bts = await _bts.startBlueToothService(_flutterBlue);

    Widget pastdataButton = TextButton(
      child: const Text(VIEWPASTDATA),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    Widget readButton = TextButton(
      child: const Text(READ),
      onPressed: () {
        Navigator.of(context).pop();
        Navigator.pushNamed(
          context,
          '/capture',
          arguments: CaptureDataPage(
              title: CAPTUREDATAPAGETITLE,
              flutterBlue: _flutterBlue,
              bluetoothConnectionService: _bts),
        );
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //       builder: (context) => CaptureDataPage(
        //         title: CAPTUREDATAPAGETITLE, flutterBlue: flutterBlue, bluetoothConnectionService: bts
        //       ),
        //   ),
        // );
      },
    );

    Widget retryButton = TextButton(
      child: const Text(SCANAGAIN),
      onPressed: () {
        rescan();
        Navigator.of(context).pop();
      },
    );

    if (_bts.deviceReady) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(BLUETOOTH),
              content: Text(PULSEOXIMETERFOUND),
              actions: [readButton, pastdataButton],
            );
          });
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(BLUETOOTH),
              content: const Text('Bluetooth is turned off  or' +
                  "\n" +
                  'EW Pulse Oxmeter not found.'),
              actions: [retryButton, pastdataButton],
            );
          });
    }
  }

  void rescan() {
    WidgetsBinding.instance
        ?.addPostFrameCallback((timeStamp) => runBluetoothSetup(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text('Report Page'),
          ],
        ),
      ),
    );
  }
}
