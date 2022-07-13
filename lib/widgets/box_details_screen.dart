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
  _addDeviceTolist(final DiscoveredDevice device) {
    if (device.id == widget.selectedBox.id) {
      setState(() {
        log(device.toString());
        log('found it');
        setState(() {
          _bleService.discoveredDevice = device;
          _bleService.isCurrentlySelectedDeviceActive = true;
          log('set _bleService.foundDeviceWaitingToConnect = true;');
        });
      });
    }
  }

  bool _isCurrentDeviceDiscovered() {
    if (_bleService.discoveredDevice.id == widget.selectedBox.id) {
      log("yep it's the selected device");
      return true;
    } else {
      return false;
    }
  }

  void _stopScan() async {
    // We're done scanning, we can cancel it
    _bleService.scanStream.cancel();
    setState(() {
      _bleService.scanStarted = false;
    });
    log('stopped scanning');
  }

  void _startScan() async {
    // Platform permissions handling stuff
    // _bleService.discoveredDevice;
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
      }, onError: (Object e) {
        log('Device scan fails with error: $e');
        _bleService.handleError(e, context);
      });
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
    // log();
    // List<String> itemImages = widget.selectedBox.item_images ?? [];
    // if (itemImages.length == 0) {
    //   itemImages = [
    //     'https://enso-box.s3.eu-central-1.amazonaws.com/Allura+-+Park.png'
    //   ];
    // }
    if (!_bleService.scanStarted) {
      _startScan();
    }
    return WillPopScope(
      onWillPop: () async {
        _stopScan();
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
              child: Image.network(widget.selectedBox.item_images != null &&
                      widget.selectedBox.item_images!.isNotEmpty
                  ? widget.selectedBox.item_images!.first
                  : 'https://enso-box.s3.eu-central-1.amazonaws.com/Allura+-+Park.png'), //https://stackoverflow.com/questions/72951044/access-first-element-of-a-nullable-liststring-in-dart/72951153?noredirect=1#comment128852739_72951153
            ),
            _createStatusTile(),
            const Divider(
              height: 1.0,
            ),
          ],
        ),

        // _buildListViewOfDevices(),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.blue,
                ),
                label: "Zurück"),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.done_all,
                  color: Colors.blue,
                ),
                label: "Jetzt ausleihen"),
          ],
          onTap: (int itemIndex) {
            log("Pressed" + itemIndex.toString());
            switch (itemIndex) {
              case 0:
                Navigator.pop(context);
                break;
              case 1:
                log("Pressed 111" + itemIndex.toString());
                _bleService.connectToDevice();
                goToPayment(context);
            }
          },
        ),
        // persistentFooterButtons: [
        //   // We want to enable this button if the scan has NOT started
        //   // If the scan HAS started, it should be disabled.
        //   _bleService.scanStarted
        //       // True condition
        //       ? ElevatedButton(
        //           style: ElevatedButton.styleFrom(
        //             primary: Colors.grey, // background
        //             onPrimary: Colors.white, // foreground
        //           ),
        //           onPressed: () {},
        //           child: const Icon(Icons.search),
        //         )
        //       // False condition
        //       : ElevatedButton(
        //           style: ElevatedButton.styleFrom(
        //             primary: Colors.blue, // background
        //             onPrimary: Colors.white, // foreground
        //           ),
        //           onPressed: _startScan,
        //           child: const Icon(Icons.search),
        //         ),
        //   _bleService.foundDeviceWaitingToConnect
        //       // True condition
        //       ? ElevatedButton(
        //           style: ElevatedButton.styleFrom(
        //             primary: Colors.blue, // background
        //             onPrimary: Colors.white, // foreground
        //           ),
        //           onPressed: _connectToDevice,
        //           child: const Icon(Icons.bluetooth),
        //         )
        //       // False condition
        //       : ElevatedButton(
        //           style: ElevatedButton.styleFrom(
        //             primary: Colors.grey, // background
        //             onPrimary: Colors.white, // foreground
        //           ),
        //           onPressed: () {},
        //           child: const Icon(Icons.bluetooth),
        //         ),
        //   _bleService.connected
        //       // True condition
        //       ? ElevatedButton(
        //           style: ElevatedButton.styleFrom(
        //             primary: Colors.blue, // background
        //             onPrimary: Colors.white, // foreground
        //           ),
        //           onPressed: _partyTime,
        //           child: const Icon(Icons.celebration_rounded),
        //         )
        //       // False condition
        //       : ElevatedButton(
        //           style: ElevatedButton.styleFrom(
        //             primary: Colors.grey, // background
        //             onPrimary: Colors.white, // foreground
        //           ),
        //           onPressed: () => goToPayment(context),
        //           child: const Icon(Icons.celebration_rounded),
        //         ),
        // ],
      ),
    );
  }

  ListTile _createStatusTile() {
    if (_bleService.isCurrentlySelectedDeviceActive) {
      return new ListTile(
        leading: const Icon(Icons.bluetooth_connected),
        title: Text('Bluetooth Verbindung hergestellt'),
        subtitle: Text(
            'Dein Handy konnte eine Bluetooth Verbindung zur ${widget.selectedBox.name} herstellen.'),
      );
    } else {
      return new ListTile(
        leading: const Icon(Icons.bluetooth_searching),
        title: Text('Keine Bluetooth Verbindung'),
        subtitle: Text(
            'Dein Handy konnte keine Bluetooth Verbindung zur ${widget.selectedBox.name} herstellen. Hast du dein Bluetooth aktiviert?'),
      );
    }
  }
}
