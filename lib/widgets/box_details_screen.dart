import 'dart:async';
import 'dart:developer';
import 'dart:io' show Platform;

import 'package:ensobox/widgets/ble/bluetooth_service.dart';
import 'package:ensobox/widgets/pay.dart';
import 'package:ensobox/widgets/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:location_permissions/location_permissions.dart';

import '../models/locations.dart' as locations;

BluetoothService _bleService = getIt<BluetoothService>();

class BoxDetailsScreen extends StatefulWidget {
  final List<locations.Box> boxes;
  final locations.Box selectedBox;

  BoxDetailsScreen(this.boxes, this.selectedBox);

  @override
  State<StatefulWidget> createState() => _BoxDetailsScreenState();

// void selectCategory(BuildContext ctx, locations.Box selectedBox) {
//   Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
//     return BoxDetailsScreen(_boxes, selectedBox);
//   }));
// }
}

class _BoxDetailsScreenState extends State<BoxDetailsScreen> {
  ListView _buildListViewOfDevices() {
    List<Container> containers = <Container>[];
    for (DiscoveredDevice device in _bleService.devicesList) {
      containers.add(
        Container(
          height: 50,
          child: Row(
            children: <Widget>[
              Container(
                height: 50,
                width: 100,
                child: Column(
                  children: <Widget>[
                    Text(device.name == '' ? '(unknown device)' : device.name),
                    Text(device.id.toString()),
                  ],
                ),
              ),
              FlatButton(
                color: Colors.blue,
                child: Text(
                  'Verbinden',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.only(left: 4, bottom: 8, right: 4, top: 50),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  _addDeviceTolist(final DiscoveredDevice device) {
    if (_bleService.devicesList
                .indexWhere((deviceInList) => device.id == deviceInList.id) ==
            -1 &&
        device.id == widget.selectedBox.id) {
      setState(() {
        _bleService.devicesList.add(device);
        log(device.toString());
        log('current devicesList: ${_bleService.devicesList}');
        log('found it');
        setState(() {
          _bleService.discoveredDevice = device;
          _bleService.foundDeviceWaitingToConnect = true;
        });
      });
    }
  }

  void _startScan() async {
// Platform permissions handling stuff
    bool permGranted = false;
    setState(() {
      _bleService.scanStarted = true;
    });
    PermissionStatus permission;
    log('started scanning');
    log("the boxes: " + widget.boxes.length.toString());
    log("the selected box: " + widget.selectedBox.id);
    if (Platform.isAndroid) {
      log('Platform.isAndroid: $Platform.isAndroid');
      permission = await LocationPermissions().requestPermissions();
      if (permission == PermissionStatus.granted) {
        permGranted = true;
        log('permGranted: $permGranted');
      }
    } else if (Platform.isIOS) {
      permGranted = true;
      log('permGranted on iOS: $permGranted');
    }
// Main scanning logic happens here ⤵️
    if (permGranted) {
      log('_scanStream started: $permGranted');
      _bleService.scanStream = _bleService.flutterReactiveBle
          .scanForDevices(withServices: []).listen((device) {
        // Change this string to what you defined in Zephyr

        // log('device: $device.name');
        _addDeviceTolist(device);
      });
    }
  }

  void _connectToDevice() {
    // We're done scanning, we can cancel it
    _bleService.scanStream.cancel();
    log("Trying to connect to " + _bleService.discoveredDevice.id);
    log("characteristicUuid " + _bleService.characteristicUuid.toString());
    // Let's listen to our connection so we can make updates on a state change
    Stream<ConnectionStateUpdate> _currentConnectionStream =
        _bleService.flutterReactiveBle.connectToAdvertisingDevice(
            id: _bleService.discoveredDevice.id,
            prescanDuration: const Duration(seconds: 1),
            withServices: [
          Uuid.parse("4fafc201-1fb5-459e-8fcc-c5c9c331914b"),
          _bleService.characteristicUuid
        ]);
    _currentConnectionStream.listen((event) {
      switch (event.connectionState) {
        // We're connected and good to go!
        case DeviceConnectionState.connected:
          {
            _bleService.rxCharacteristic = QualifiedCharacteristic(
                serviceId: _bleService.serviceUuid,
                characteristicId: _bleService.characteristicUuid,
                deviceId: event.deviceId);
            setState(() {
              _bleService.foundDeviceWaitingToConnect = false;
              _bleService.connected = true;
            });
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

  void _partyTime() {
    if (_bleService.connected) {
      _bleService.flutterReactiveBle.writeCharacteristicWithResponse(
          _bleService.rxCharacteristic,
          value: [
            0xff,
          ]);
    }
  }

  void goToPayment(BuildContext ctx) {
    Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
      return Pay();
    }));
  }

  @override
  Widget build(BuildContext context) {
    // String itemUrl = widget.selectedBox.item_images?[0] ??
    //     'https://enso-box.s3.eu-central-1.amazonaws.com/Allura+-+Park.png';
    List<String> itemImages = widget.selectedBox.item_images ?? [];
    if (itemImages.length == 0) {
      itemImages = [
        'https://enso-box.s3.eu-central-1.amazonaws.com/Allura+-+Park.png'
      ];
    }

    if (_bleService.scanStarted) {
      _startScan();
    }
    return WillPopScope(
      onWillPop: () async {
        _bleService.devicesList = [];
        // Returning true allows the pop to happen, returning false prevents it.
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('${widget.selectedBox.name}'),
          backgroundColor: Colors.green[700],
        ),
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * .35,
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.only(bottom: 30),
              child: Image.network(itemImages[0]),
            ),
            _buildListViewOfDevices(),
          ],
        ),
        persistentFooterButtons: [
          // We want to enable this button if the scan has NOT started
          // If the scan HAS started, it should be disabled.
          _bleService.scanStarted
              // True condition
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.grey, // background
                    onPrimary: Colors.white, // foreground
                  ),
                  onPressed: () {},
                  child: const Icon(Icons.search),
                )
              // False condition
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue, // background
                    onPrimary: Colors.white, // foreground
                  ),
                  onPressed: _startScan,
                  child: const Icon(Icons.search),
                ),
          _bleService.foundDeviceWaitingToConnect
              // True condition
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue, // background
                    onPrimary: Colors.white, // foreground
                  ),
                  onPressed: _connectToDevice,
                  child: const Icon(Icons.bluetooth),
                )
              // False condition
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.grey, // background
                    onPrimary: Colors.white, // foreground
                  ),
                  onPressed: () {},
                  child: const Icon(Icons.bluetooth),
                ),
          _bleService.connected
              // True condition
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue, // background
                    onPrimary: Colors.white, // foreground
                  ),
                  onPressed: _partyTime,
                  child: const Icon(Icons.celebration_rounded),
                )
              // False condition
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.grey, // background
                    onPrimary: Colors.white, // foreground
                  ),
                  onPressed: () => goToPayment(context),
                  child: const Icon(Icons.celebration_rounded),
                ),
        ],
      ),
    );
  }
}
