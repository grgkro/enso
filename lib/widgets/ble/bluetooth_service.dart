import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BluetoothService {
  List<DiscoveredDevice> devicesList = <DiscoveredDevice>[];
  // Some state management stuff
  bool _foundDeviceWaitingToConnect = false;
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

  bool get foundDeviceWaitingToConnect => _foundDeviceWaitingToConnect;

  set foundDeviceWaitingToConnect(bool value) {
    _foundDeviceWaitingToConnect = value;
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
}
