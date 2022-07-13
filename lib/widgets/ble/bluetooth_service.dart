import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BluetoothService {
  // Some state management stuff
  bool _isCurrentlySelectedDeviceActive = false;
  bool _scanStarted = false;
  bool _connected = false;
// Bluetooth related variables
  late DiscoveredDevice _discoveredDevice;
  final flutterReactiveBle = FlutterReactiveBle();
  late StreamSubscription<DiscoveredDevice> _scanStream;
  late QualifiedCharacteristic _rxCharacteristic;
// These are the UUIDs of your device
  final Uuid serviceUuid = Uuid.parse("75C276C3-8F97-20BC-A143-B354244886D4");
  final Uuid characteristicUuid =
      Uuid.parse("6ACF4F08-CC9D-D495-6B41-AA7E60C4E8A6");

  void connectToDevice() {
    // We're done scanning, we can cancel it
    scanStream.cancel();
    log("Trying to connect to " + discoveredDevice.id);
    log("characteristicUuid " + characteristicUuid.toString());
    // Let's listen to our connection so we can make updates on a state change
    Stream<ConnectionStateUpdate> _currentConnectionStream = flutterReactiveBle
        .connectToAdvertisingDevice(
            id: discoveredDevice.id,
            prescanDuration: const Duration(seconds: 1),
            withServices: [
          Uuid.parse("4fafc201-1fb5-459e-8fcc-c5c9c331914b"),
          characteristicUuid
        ]);
    _currentConnectionStream.listen((event) {
      switch (event.connectionState) {
        // We're connected and good to go!
        case DeviceConnectionState.connected:
          {
            rxCharacteristic = QualifiedCharacteristic(
                serviceId: serviceUuid,
                characteristicId: characteristicUuid,
                deviceId: event.deviceId);
            // setState(() {
            isCurrentlySelectedDeviceActive = false;
            connected = true;
            // });
            break;
          }
        // Can add various state state updates on disconnect
        case DeviceConnectionState.disconnected:
          {
            break;
          }
        default:
      }
    });
  }

  bool get isCurrentlySelectedDeviceActive => _isCurrentlySelectedDeviceActive;

  set isCurrentlySelectedDeviceActive(bool value) {
    _isCurrentlySelectedDeviceActive = value;
  }

  bool get scanStarted => _scanStarted;

  set scanStarted(bool value) {
    _scanStarted = value;
  }

  QualifiedCharacteristic get rxCharacteristic => _rxCharacteristic;

  set rxCharacteristic(QualifiedCharacteristic value) {
    _rxCharacteristic = value;
  }

  StreamSubscription<DiscoveredDevice> get scanStream => _scanStream;

  set scanStream(StreamSubscription<DiscoveredDevice> value) {
    _scanStream = value;
  }

  DiscoveredDevice get discoveredDevice => _discoveredDevice;

  set discoveredDevice(DiscoveredDevice value) {
    _discoveredDevice = value;
  }

  bool get connected => _connected;

  set connected(bool value) {
    _connected = value;
  }

  void _partyTime() {
    if (connected) {
      flutterReactiveBle
          .writeCharacteristicWithResponse(rxCharacteristic, value: [
        0xff,
      ]);
    }
  }

  void handleError(Object e, BuildContext context) {
    var re = RegExp(r'(?<=message: ")(.*)(?=\()');
    log(e.toString());
    var match = re.firstMatch(e.toString());
    if (match != null) print(match.group(0));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
          Text(match!.group(0) ?? "Bitte prüfen, ob Bluetooth aktiviert ist."),
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: 'AKTIVIEREN',
        onPressed: () {},
      ),
    ));

    // String errorMessage =
    //   switch (status) {
    //     case BleStatus.unsupported:
    //       return "This device does not support Bluetooth";
    //     case BleStatus.unauthorized:
    //       return "Authorize the FlutterReactiveBle example app to use Bluetooth and location";
    //     case BleStatus.poweredOff:
    //       return "Bluetooth is powered off on your device turn it on";
    //     case BleStatus.locationServicesDisabled:
    //       return "Enable location services";
    //     case BleStatus.ready:
    //       return "Bluetooth is up and running";
    //     default:
    //       return "Waiting to fetch Bluetooth status $status";
    //   }
    // }
  }
}
