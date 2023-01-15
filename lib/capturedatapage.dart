//Copyright 2023 Emerson Warwick Limited

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'bluetooth.dart';
import 'constants.dart';


class CaptureDataPage extends StatefulWidget {
  const CaptureDataPage(
      {
        Key? key,
        required this.title,
        required this.flutterBlue,
        required this.bluetoothConnectionService,
      }) : super(key: key);

  final String title;
  final FlutterBlue flutterBlue;
  final BluetoothConnectionService bluetoothConnectionService;

  @override
  State<CaptureDataPage> createState() => _CaptureDataPageState();
}

class _CaptureDataPageState extends State<CaptureDataPage> {

  late FlutterBlue _flutterBlue;
  late BluetoothConnectionService _bts;

  double _SpO2 = 0;
  double _heartRate = 0;
  MaterialColor startButtonColour = Colors.green;
  MaterialColor stopButtonColour = Colors.grey;


  @override
  void initState() {
    super.initState();
    _flutterBlue = widget.flutterBlue;
    _bts = widget.bluetoothConnectionService;
  }

  Future<void> setNotify() async {
    await _bts.pulseOximeterChar.setNotifyValue(true);
    _bts.pulseOximeterChar.value.listen((event) {
      if (event.isNotEmpty){
        _SpO2 = event[1].toDouble();
        refreshPage();
      }
    });
    await _bts.pulseRateChar.setNotifyValue(true);
    _bts.pulseRateChar.value.listen((event) {
      if (event.isNotEmpty){
        _heartRate = event[1].toDouble();
        refreshPage();
      }
    });
    startButtonColour = Colors.grey;
    stopButtonColour = Colors.red;
  }

  Future<void> stopNotify() async {
    await _bts.pulseOximeterChar.setNotifyValue(false);
    await _bts.pulseRateChar.setNotifyValue(false);
    startButtonColour = Colors.green;
    stopButtonColour = Colors.grey;
    refreshPage();
  }

  void refreshPage(){
    setState(() {
    });
  }

  Widget spO2Guarge(double _spo2_value) {
    return Container(
        child: SfRadialGauge(
            axes:<RadialAxis>[
              RadialAxis(
                minimum: 40,
                maximum: 100,
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(widget: Container(child:
                  Text('SpO2 = ${_spo2_value.toInt()}%',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold))),
                      angle: 90, positionFactor: 0.9
                  )],
                pointers: <GaugePointer>[
                  NeedlePointer(value: _spo2_value, needleEndWidth: 1,)],
              ),
            ]
        ));
  }

  Widget hrGuarge(double _hr_value) {
    return Container(
        child: SfRadialGauge(
            axes:<RadialAxis>[
              RadialAxis(
                minimum: 40,
                maximum: 210,
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(widget: Container(child:
                  Text('HR = ${_hr_value.toInt()}',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold))),
                      angle: 90, positionFactor: 0.9
                  )],
                pointers: <GaugePointer>[
                  NeedlePointer(value: _hr_value, needleEndWidth: 1,)],
              ),
            ],
        ),
    );
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
          children: <Widget>[
            StreamBuilder<List<BluetoothService>>(
              stream: _bts.device.services,
              builder: (c, snapshot) {
                return Column(
                  children: <Widget>[
                    Container(
                      height: 200,
                      child: spO2Guarge(_SpO2),
                    ),
                    Container(
                      height: 200,
                      child: hrGuarge(_heartRate),
                    ),
                    Container(
                        margin: const EdgeInsets.all(10.0),
                        height: 56, width: 180,
                        child: ElevatedButton(onPressed: () { setNotify(); }, child: Text(START), style: ElevatedButton.styleFrom(primary: startButtonColour )),
                    ),
                    Container(
                        margin: const EdgeInsets.all(10.0),
                        height: 56, width: 180,
                        child: ElevatedButton(onPressed: () {
                          stopNotify();
                          }, child: Text(STOP), style: ElevatedButton.styleFrom(primary: stopButtonColour ),),
                    ),
                  ],
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}