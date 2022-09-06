import 'dart:developer';

import 'package:ensobox/widgets/provider/current_user_provider.dart';
import 'package:ensobox/widgets/service_locator.dart';
import 'package:ensobox/widgets/services/global_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:provider/provider.dart';

import '../models/enso_user.dart';
import 'box_list.dart';
import 'enso_drawer.dart';
import 'firebase_repository/auth_repo.dart';
import 'firestore_repository/database_repo.dart';
import 'globals/enso_divider.dart';
import '../models/locations.dart' as locations;

AuthRepo _authRepo = getIt<AuthRepo>();
GlobalService _globalService = getIt<GlobalService>();
final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
DatabaseRepo _databaseRepo = getIt<DatabaseRepo>();

class MapItemOverviewScreen extends StatefulWidget {
  const MapItemOverviewScreen({Key? key}) : super(key: key);

  @override
  State<MapItemOverviewScreen> createState() => _MapItemOverviewScreenState();
}

class _MapItemOverviewScreenState extends State<MapItemOverviewScreen> {
  final Map<String, Marker> _markers = {};

  Future<void> _onMapCreated(GoogleMapController controller) async {
    var ensoBoxes = await locations.getBoxLocations();
    setState(() {
      _markers.clear();
      for (final box in ensoBoxes.boxes) {
        log(box.id);
        final marker = Marker(
          markerId: MarkerId(box.name),
          position:
          LatLng(box.lat ?? 48.7553846205735, box.lng ?? 9.172653858386855),
          infoWindow: InfoWindow(
            title: box.name,
            snippet: box.address,
          ),
        );
        _markers[box.name] = marker;
      }
    });
  }

  Text getMainText() {
    return Text('Tippe auf den Gegenstand, den du gerne ausleihen möchtest:',
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
            fontSize: 16));
  }

  void startListeningForEnsoUserChanges(BuildContext context) {
    final currentUserProvider =
    Provider.of<CurrentUserProvider>(context, listen: false);

    _firebaseAuth.authStateChanges().listen((User? authUser) async {
      if (authUser != null) {
        log("The user is now signed in and stored in the globalService: ${authUser.toString()}");
        _globalService.currentAuthUser = authUser;
        _globalService.isSignedIn = true;
        if (currentUserProvider.currentEnsoUser.id == null || authUser.uid != currentUserProvider.currentEnsoUser.id) {
          EnsoUser? currentEnsoUser =
          await _databaseRepo.getUserFromDB(authUser.uid);
          if (currentEnsoUser != null) {
            log("The EnsoUser was retrieved from the DB and is now stored in the globalService: ${currentEnsoUser.toString()}");
            currentUserProvider.setCurrentEnsoUser(currentEnsoUser);
          } else {
            log("Getting the EnsoUser from the DB with this id ${authUser.uid} failed.");
          }
        } else {
          log("The EnsoUser was already retrieved from the DB with this id ${authUser.uid}, no update needed.");
        }
      } else {
        _globalService.isSignedIn = false;
        print(
            "User is not signed in, _auth.authStateChanges().listen() returned null");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    startListeningForEnsoUserChanges(context);

    User? currentUser = _globalService.currentAuthUser;
    final currentUserProvider =
    Provider.of<CurrentUserProvider>(context, listen: false);
    EnsoUser currentEnsoUser = currentUserProvider.currentEnsoUser;

    if (!_globalService.hasShownEmailAppSnackBar && currentEnsoUser.id != null && !currentEnsoUser.emailVerified && currentEnsoUser.hasTriggeredConfirmationEmail) {
      Future.delayed(Duration.zero,() {
        log('Widget is rendered completely!');
        showOpenMailAppSnack(context);
      });
    }

    return SafeArea(
        child: Column(
          children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context)
                  .size
                  .width, // or use fixed size like 200
              height: MediaQuery.of(context).size.height / 2.3,

              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(48.7553846205735, 9.172653858386855),
                  zoom: 14,
                ),
                markers: _markers.values.toSet(),
              ),
            ),
            const EnsoDivider(),
            getMainText(),
            const EnsoDivider(),
            Expanded(
              child: Container(
                width: MediaQuery.of(context)
                    .size
                    .width, // or use fixed size like 200
                // height: MediaQuery.of(context).size.height / 2 - 100,
                child: BoxList(),
              ),
            ),
          ],
        ),
    );
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
  showOpenMailAppSnack(BuildContext context) {
    _globalService.hasShownEmailAppSnackBar = true;
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text("Email zur Bestätigung gesendet, bitte bestätigen."),
      duration: const Duration(seconds: 15),
      action: SnackBarAction(
        label: 'Mail App auswählen',
        onPressed: () async {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          final OpenMailAppResult result = await OpenMailApp.openMailApp();

          // If no mail apps found, show error
          if (!result.didOpen && !result.canOpen) {
            showNoMailAppsDialog(context);

            // iOS: if multiple mail apps found, show dialog to select.
            // There is no native intent/default app system in iOS so
            // you have to do it yourself.
          } else if (!result.didOpen && result.canOpen) {
            showDialog(
              context: context,
              builder: (_) {
                return MailAppPickerDialog(
                  mailApps: result.options,
                );
              },
            );
          }
        },
      ),
    ));
  }

  void showNoMailAppsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Open Mail App"),
          content: Text("No mail apps installed"),
          actions: <Widget>[
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }
}
