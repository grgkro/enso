import 'dart:developer';
import 'dart:io' show Platform;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ensobox/models/enso_user.dart';
import 'package:ensobox/models/item.dart';
import 'package:ensobox/widgets/ble/bluetooth_service.dart';
import 'package:ensobox/widgets/firestore_repository/database_repo.dart';
import 'package:ensobox/widgets/pay.dart';
import 'package:ensobox/widgets/provider/current_user_provider.dart';
import 'package:ensobox/widgets/service_locator.dart';
import 'package:ensobox/widgets/services/global_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:provider/provider.dart';

import '../models/locations.dart' as locations;
import 'auth/verification_overview_screen.dart';
import 'globals/enso_circular_progress_indicator.dart';
import 'globals/enso_divider.dart';

BluetoothService _bleService = getIt<BluetoothService>();
GlobalService _globalService = getIt<GlobalService>();
DatabaseRepo _databaseRepo = getIt<DatabaseRepo>();

class ItemDetailsScreen extends StatefulWidget {
  final List<locations.Box> boxes;
  final locations.Box selectedBox;
  final Item selectedItem;

  ItemDetailsScreen(this.boxes, this.selectedBox, this.selectedItem);

  @override
  State<StatefulWidget> createState() => _ItemDetailsScreenState();

// void selectCategory(BuildContext ctx, locations.Box selectedBox) {
//   Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
//     return BoxDetailsScreen(_boxes, selectedBox);
//   }));
// }
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  String getBackgroundImageUrl() {
    String url = "";
    if (widget.selectedItem.item_images != null &&
        widget.selectedItem.item_images!.isNotEmpty) {
      // url = widget.selectedBox.items.first;
      url = widget.selectedItem.item_images![0];
    } else {
      url = 'https://enso-box.s3.eu-central-1.amazonaws.com/Allura+-+Park.png';
    }
    return url;
  }

  _checkAgainstSelectedBox(final DiscoveredDevice device) {
    if (device.id == widget.selectedBox.id) {
      log(device.toString());
      log('found it');
      if (mounted) {
        setState(() {
          _bleService.discoveredDevice = device;
          _bleService.isCurrentlySelectedDeviceActive = true;
          // _stopScan();
          log('set _bleService.foundDeviceWaitingToConnect = true;');
        });
      }
      _bleService.connectToDevice();
    }
  }

  bool _isCurrentDeviceDiscovered() {
    if (_bleService.discoveredDevice != null) {
      if (_bleService.discoveredDevice!.id == widget.selectedBox.id) {
        log("yep it's the selected device");
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  void _stopScan() async {
    // We're done scanning, we can cancel it
    if (_bleService.scanStream != null) {
      _bleService.scanStream!.cancel();
    }
    setState(() {
      _bleService.scanStarted = false;
    });
    log('stopped scanning');
  }

  void _startScan(BuildContext context) async {
    // Platform permissions handling stuff
    // _bleService.discoveredDevice;
    bool permGranted = false;
    _bleService.scanStarted = true;

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
        _checkAgainstSelectedBox(device);
      }, onError: (Object e) {
        log('Device scan failed with error: $e');
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
    if (!_bleService.scanStarted) {
      _startScan(context);
    }
    User? currentUser = _globalService.currentAuthUser;
    EnsoUser currentEnsoUser = context.read<EnsoUser>();

    bool userIsMissingNecessaryVerification() {
      if (currentUser == null) {
        // user was not registered before
        return true;
      } else {
        // TODO: Check if currentUser.emailVerified can be used in the if statement
        if (currentEnsoUser.emailVerified &&
            currentEnsoUser.phoneVerified &&
            currentEnsoUser.idUploaded) {
          return false;
        } else {
          return true;
        }
      }
    }

    return WillPopScope(
      onWillPop: () async {
        _stopScan();
        // Returning true allows the pop to happen, returning false prevents it.
        return true;
      },
      child:
          // CustomScrollView(
          //   slivers: <Widget>[
          //     SliverAppBar(
          //       pinned: true,
          //       floating: false,
          //       expandedHeight: 250.0,
          //       flexibleSpace: FlexibleSpaceBar(
          //         centerTitle: true,
          //         title: Text(
          //           "${widget.selectedItem.name} ${widget.selectedItem.model}",
          //           style: TextStyle(
          //             color: Colors.black,
          //             fontSize: 16.0,
          //           ),
          //           overflow: TextOverflow.ellipsis,
          //           maxLines: 1,
          //           softWrap: false,
          //         ), //Text
          //         background: Image.network(
          //           getBackgroundImageUrl(),
          //           fit: BoxFit.cover,
          //         ),
          //       ),
          //     ),
          //     // _createStatusTile(),
          //     SliverToBoxAdapter(
          //       child: SizedBox(
          //         height: MediaQuery.of(context).size.height,
          //         width: MediaQuery.of(context).size.width,
          //         child: Scaffold(
          //           body: SingleChildScrollView(
          //             child: Column(
          //               children: [
          //                 const EnsoDivider(),
          //                 _createStatusTile(),
          //                 const EnsoDivider(),
          //                 _createExplanationText(),
          //               ],
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ],
          // ),

          Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title:
              Text('${widget.selectedItem.name} ${widget.selectedItem.model}'),
          backgroundColor: Colors.green[700],
        ),
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * .35,
                width: MediaQuery.of(context).size.width,
                // padding: const EdgeInsets.only(bottom: 30),
                child: Hero(
                    tag: getBackgroundImageUrl(),
                    child: CachedNetworkImage(
                        imageUrl: getBackgroundImageUrl(),
                        placeholder: (context, url) {
                          return const EnsoCircularProgressIndicator();
                        },
                        errorWidget: (context, url, error) {
                          log('ERROR: could not load image, going to show placeholder instead. url: ${url}, error: ${error.toString()}');
                          return Image.asset('assets/img/placeholder_item.png');
                        })),
              ),
              const EnsoDivider(),
              _createStatusTile(),
              const EnsoDivider(),
              _createExplanationText(),
            ],
          ),
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
                // if (_isCurrentDeviceDiscovered()) {
                //   _bleService.connectToDevice();
                if (userIsMissingNecessaryVerification()) {
                  _globalService.showScreen(
                      context, VerificationOverviewScreen());
                } else if (currentEnsoUser.idApproved) {
                  log("let's go to the renting screen!");
                  // _globalService.showScreen(context, RentingScreen);
                } else {
                  log("let's go to the wait-for-approval screen!");
                  // _globalService.showScreen(context, WaitForApprovalScreen);
                }
              // } else {
              //   log("currently selected box is not connected");
              // }
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
    if (_bleService.isCurrentlySelectedDeviceActive &&
        _bleService.discoveredDevice != null &&
        _bleService.discoveredDevice!.id == widget.selectedBox.id) {
      return ListTile(
        leading: const Icon(Icons.bluetooth_connected),
        title: Text(
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 20),
            'Bluetooth Verbindung hergestellt'),
        subtitle: Text(
            textAlign: TextAlign.left,
            style: const TextStyle(fontSize: 16),
            'Dein Handy konnte eine Bluetooth Verbindung zur ${widget.selectedBox.name} herstellen.'),
      );
    } else {
      return ListTile(
        leading: const Icon(Icons.bluetooth_searching),
        title: Text('Keine Bluetooth Verbindung'),
        subtitle: Text(
            'Dein Handy konnte keine Bluetooth Verbindung zur ${widget.selectedBox.name} herstellen. Hast du dein Bluetooth aktiviert?'),
      );
    }
  }

  _createExplanationText() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: Text(
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontSize: 20),
                        '${widget.selectedItem.description1}'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: Text(
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontSize: 20),
                        '${widget.selectedItem.description2}'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: Text(
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontSize: 20),
                        '${widget.selectedItem.description3}'),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
