import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BluetoothService {
  // Some state management stuff
  bool _isCurrentlySelectedDeviceActive = false;
  bool _scanStarted = false;
  bool _connected = false;

// Bluetooth related variables
  DiscoveredDevice? discoveredDevice;
  final flutterReactiveBle = FlutterReactiveBle();
  StreamSubscription<DiscoveredDevice>? scanStream;
  QualifiedCharacteristic? rxCharacteristic;

// These are the UUIDs of your device
  final Uuid serviceUuid = Uuid.parse("75C276C3-8F97-20BC-A143-B354244886D4");
  final Uuid characteristicUuid =
      Uuid.parse("6ACF4F08-CC9D-D495-6B41-AA7E60C4E8A6");
  final Uuid characteristicUuidEnso =
      Uuid.parse("beb5483e-36e1-4688-b7f5-ea07361b26a8");

  void connectToDevice() {
    if (discoveredDevice != null) {
      // We're done scanning, we can cancel it
      if (scanStream != null) {
        scanStream?.cancel();
      }
      log("Trying to connect to ${discoveredDevice!.id}");
      log("characteristicUuid $characteristicUuid");
      flutterReactiveBle.connectToDevice(id: discoveredDevice!.id).listen(
        (update) async {
          // _deviceConnectionController.add(update);
          print(
              'ConnectionState for device ${discoveredDevice!.name} : ${update.connectionState}');
          try {
            final characteristic = QualifiedCharacteristic(
                serviceId: serviceUuid,
                characteristicId: characteristicUuidEnso,
                deviceId: discoveredDevice!.id);
            final response =
                await flutterReactiveBle.readCharacteristic(characteristic);

            log('Read characterisitc from ESP: ${characteristic.characteristicId}: value = $response');
            log('DECODED: ${AsciiDecoder().convert(response, 0)}');
            log('DECODED: ${String.fromCharCodes(response)}');
            log('ENCODED: ${AsciiEncoder().convert("response", 0)}');

            try {
              flutterReactiveBle
                  .writeCharacteristicWithResponse(characteristic,
                      value: AsciiEncoder().convert("response", 0))
                  .then((value) => log(
                      'Write successful: ${characteristic.characteristicId}'));
              log('Wrote characteristic to ESP: ${characteristic.characteristicId}: value = $response');
            } catch (e) {
              log("Wrote characteristic, got exception: $e");
            }

            // return result;
          } on Exception catch (e, s) {
            log(
              'Error occured when reading ${characteristicUuidEnso} : $e',
            );
            // ignore: avoid_print
            print(s);
            // rethrow;
          }
        },
        onError: (Object e) => print(
            'Connecting to device ${discoveredDevice!.name} resulted in error $e'),
      );
    } else {
      log("Warn: No device has been discovered before calling connectToDevice",
          level: 1);
    }
  }

  bool get isCurrentlySelectedDeviceActive => _isCurrentlySelectedDeviceActive;

  set isCurrentlySelectedDeviceActive(bool value) {
    _isCurrentlySelectedDeviceActive = value;
  }

  bool get scanStarted => _scanStarted;

  set scanStarted(bool value) {
    _scanStarted = value;
  }

  bool get connected => _connected;

  set connected(bool value) {
    _connected = value;
  }

  void _partyTime() {
    if (connected) {
      if (rxCharacteristic != null) {
        flutterReactiveBle
            .writeCharacteristicWithResponse(rxCharacteristic!, value: [
          0xff,
        ]);
      }
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
