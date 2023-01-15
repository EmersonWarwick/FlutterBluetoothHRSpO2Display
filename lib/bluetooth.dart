//Copyright 2023 Emerson Warwick Limited

import 'dart:async';
import 'package:flutter_blue/flutter_blue.dart';

import 'constants.dart';

class BluetoothConnectionService {
  late BluetoothDevice device;
  bool PulseOximeterFound = false;
  late List<BluetoothService> services;
  late BluetoothService pulseOximeterService;
  bool foundPulseOximeterService = false;
  late BluetoothService pulseRateService;
  bool foundPulseRateService = false;
  late BluetoothCharacteristic pulseOximeterChar;
  late BluetoothCharacteristic pulseRateChar;
  bool deviceReady = false;
  bool serviceAvailable = false;

  BluetoothConnectionService._();

  static final BluetoothConnectionService _instance =
      BluetoothConnectionService._();
  static BluetoothConnectionService get instance => _instance;

  Future<BluetoothConnectionService> startBlueToothService(
      FlutterBlue flutterBlue) async {
    serviceAvailable = await flutterBlue.isOn;
    if (serviceAvailable) {
      await startBle(flutterBlue);
      return this;
    } else {
      return this;
    }
  }

  Future<BluetoothConnectionService> startBle(FlutterBlue flutterBlue) async {
    flutterBlue.startScan(timeout: Duration(seconds: 10));

    flutterBlue.scanResults.listen((results) async {
      // Wait for list to build
      await Future.delayed(Duration(seconds: 1));
      for (ScanResult r in results) {
        if (r.device.name == 'EW Pulse Oximeter') {
          device = r.device;
          await device.connect(); //await Future.delayed(Duration(seconds: 1));
          PulseOximeterFound = true;
          await discoverServicesBle();
          flutterBlue.stopScan();
        }
      }
    });

    int countdown = SCANTIMESECONDS;
    while (!deviceReady && countdown > 0) {
      await Future.delayed(Duration(seconds: 1));
      countdown--;
      print('countdown = ${countdown}');
    }
    return this;
  }

  bool checkUUID(Guid uuid, String serviceCode) {
    String uuidAsString = uuid.toString();
    return (uuidAsString.substring(4, 8) == serviceCode) ? true : false;
  }

  Future<void> discoverServicesBle() async {
    if (PulseOximeterFound) {
      services = await device.discoverServices();
      await discoverCharateristics();
    }
  }

  Future<void> discoverCharateristics() async {
    if (!services.isEmpty) {
      services.forEach((element) {
        if (checkUUID(element.uuid, '1822') && !foundPulseOximeterService) {
          pulseOximeterService = element;
          foundPulseOximeterService = true;
          discoverPulseOximeterCharacteristicProperty(pulseOximeterService);
        }
        if (checkUUID(element.uuid, '180d') && !foundPulseRateService) {
          pulseRateService = element;
          foundPulseRateService = true;
          discoverPulseRateCharacteristicProperty(pulseRateService);
        }
      });
    }
    deviceReady = true;
  }

  void discoverPulseOximeterCharacteristicProperty(BluetoothService service) {
    List<BluetoothCharacteristic> lc = service.characteristics;
    lc.forEach((element) {
      if (checkUUID(element.uuid, '2a5f')) {
        pulseOximeterChar = element;
      }
    });
  }

  void discoverPulseRateCharacteristicProperty(BluetoothService service) {
    List<BluetoothCharacteristic> lc = service.characteristics;
    lc.forEach((element) {
      if (checkUUID(element.uuid, '2a37')) {
        pulseRateChar = element;
      }
    });
  }

  void getPulseOxygen() {
    if (deviceReady) {}
  }

  Stream<List<int>> streamPulse() {
    while (!deviceReady) {
      Future<void>.delayed(const Duration(milliseconds: 200));
    }
    return pulseRateChar.value;
  }

  void endBle() {
    device.disconnect();
  }
}
