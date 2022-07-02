import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BLE {
  BLE();
  final frb = FlutterReactiveBle();
  StreamSubscription? subscription;
  late StreamSubscription<ConnectionStateUpdate> connection;
  late QualifiedCharacteristic tx;
  late QualifiedCharacteristic rx;
  String status = 'not connected';
  static final String BASE = "-1fb5-459e-8fcc-c5c9c331914b";
  static int response = 0;
  int value = 0;

  Future<void> stopScan() async {
    await subscription?.cancel();
    subscription = null;
  }

  String getStatus() {
    return status;
  }

  void sendData() async {
    await frb.writeCharacteristicWithoutResponse(tx, value: [0x24, 0x54]);
  }

  int readData() {
    return response;
  }

// id: 30:C6:F7:55:A4:FE
  void connectToBLE() async {
    subscription = frb.scanForDevices(
        withServices: [Uuid.parse("4fafc201" + BASE)],
        scanMode: ScanMode.lowLatency).listen((device) {
      connection = frb.connectToDevice(id: device.id).listen((state) {
        if (state.connectionState == DeviceConnectionState.connected) {
          // get tx
          tx = QualifiedCharacteristic(
              serviceId: Uuid.parse("0000ffe0" + BASE),
              characteristicId: Uuid.parse("0000ffe1" + BASE),
              deviceId: device.id);

          // get rx
          rx = QualifiedCharacteristic(
              serviceId: Uuid.parse("0000ffe0" + BASE),
              characteristicId: Uuid.parse("0000ffe1" + BASE),
              deviceId: device.id);

          // subscribe to rx
          frb.subscribeToCharacteristic(rx).listen((data) {
            value = 0;
            value += (data[0] - 48).toUnsigned(8) * 10000;
            value += (data[1] - 48).toUnsigned(8) * 1000;
            value += (data[2] - 48).toUnsigned(8) * 100;
            value += (data[3] - 48).toUnsigned(8) * 10;
            value += (data[4] - 48).toUnsigned(8) * 1;

            response = value;
          }, onError: (Object e) {
            print('subscribe error: $e\n');
          });

          status = 'connected';
          stopScan();
        }
      }, onError: (Object e) {
        // connecting error
        print('error: $e\n');
      });
    }, onError: (Object e) {
      // scan error
      print('error: $e\n');
    });
  }
}
