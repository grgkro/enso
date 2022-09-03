import 'dart:developer';
import 'dart:convert';
import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ensobox/widgets/auth/verification_overview_screen.dart';
import 'package:ensobox/widgets/enso_drawer.dart';
import 'package:ensobox/widgets/firestore_repository/functions_repo.dart';
import 'package:ensobox/widgets/provider/current_user_provider.dart';
import 'package:ensobox/widgets/services/authentication_service.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../constants/constants.dart' as Constants;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ensobox/providers/boxes.dart';
import 'package:ensobox/providers/users.dart';
import 'package:ensobox/widgets/auth/success_screen.dart';
import 'package:ensobox/widgets/box_list.dart';
import 'package:ensobox/widgets/firebase_repository/auth_repo.dart';
import 'package:ensobox/widgets/firestore_repository/database_repo.dart';
import 'package:ensobox/widgets/globals/enso_divider.dart';
import 'package:ensobox/widgets/id_scanner/mrz_scanner.dart';
import 'package:ensobox/widgets/id_scanner/user_id_details_screen.dart';
import 'package:ensobox/widgets/service_locator.dart';
import 'package:ensobox/widgets/services/global_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'models/enso_user.dart';
import 'models/locations.dart' as locations;

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
DatabaseRepo _databaseRepo = getIt<DatabaseRepo>();
GlobalService _globalService = getIt<GlobalService>();
FunctionsRepo _functionsRepo = getIt<FunctionsRepo>();
AuthRepo _authRepo = getIt<AuthRepo>();

//TODO: https://firebase.google.com/docs/firestore/quickstart#dart  Optional: Improve iOS & macOS build times by including the pre-compiled framework for Firestore
void main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  setupServiceLocator(); // This will register any services you have with GetIt before the widget tree gets built.

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          // all child widgets of MyApp widget can now listen for changes in Boxes
          create: (ctx) => Boxes(), // TODO: is this currently used?
        ),
        ChangeNotifierProvider(
          create: (ctx) => CurrentUserProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Enso Fairleihbox',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        // home: TakePictureScreen(
        //   // Pass the appropriate camera to the TakePictureScreen widget.
        //   camera: firstCamera,
        // ),
        home: const Home(),
        // home: VerificationOverviewScreen(),
        // home: SelfieExplanationScreen(),
        // initialRoute: '/', // When using initialRoute, don’t define a home property.
        routes: {
          SuccessScreen.routeName: (ctx) => SuccessScreen(),
          // MrzScanner.routeName: (ctx) => MrzScanner(),
          UserIdDetailsScreen.routeName: (ctx) => UserIdDetailsScreen()
        },
        // home: Home(),
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<Home> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final Map<String, Marker> _markers = {};
  var subscription;
  var connectionStatus;

  bool _initialized = false;
  bool _error = false;

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _globalService.isFirebaseInitialized = true;
      setState(() {
        _initialized = true;
      });

      _firebaseAuth.authStateChanges().listen((User? authUser) async {
        if (authUser != null) {
          log("The user is now signed in and stored in the globalService: ${authUser.toString()}");
          _globalService.currentAuthUser = authUser;
          _globalService.isSignedIn = true;
          if (_globalService.currentEnsoUser.id == null || authUser.uid != _globalService.currentEnsoUser.id) {
            EnsoUser? currentEnsoUser =
            await _databaseRepo.getUserFromDB(authUser.uid);
            if (currentEnsoUser != null) {
              log("The EnsoUser was retrieved from the DB and is now stored in the globalService: ${currentEnsoUser.toString()}");
              _globalService.currentEnsoUser = currentEnsoUser;
              final currentUserProvider =
              Provider.of<CurrentUserProvider>(context, listen: false);
              currentUserProvider
                  .setCurrentEnsoUser(currentEnsoUser);
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
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }

  @override
  void initState() {
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() => connectionStatus = result);
      checkInternetConnectivity();
    });

    super.initState();

    initializeFlutterFire();
  }

  @override
  dispose() {
    super.dispose();
    subscription.cancel();
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
      checkInternetConnectivity() {
    if (connectionStatus == ConnectivityResult.none) {
      return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            const Text("Bitte prüfen, ob du mit dem Internet verbunden bist."),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'WLAN AKTIVIEREN',
          onPressed: () {
            AppSettings.openWIFISettings();
          },
        ),
      ));
    } else {
      log("device has internet");
      return null;
    }
  }

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

  @override
  Widget build(BuildContext context) {
    // Show error message if initialization failed
    if (_error) {
      return MaterialApp(
          home: Scaffold(
        body: Container(
          color: Colors.white,
          child: Center(
              child: Column(
            children: const [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 25,
              ),
              SizedBox(height: 16),
              Text(
                'Es gab einen Fehler beim Initialisieren! Versuch es bitte später nochmal. Falls es weiterhin nicht klappt, mach einen Screenshot und schick ihn an support@fairleihbox.de, many thx!!',
                style: TextStyle(color: Colors.red, fontSize: 25),
              ),
            ],
          )),
        ),
      ));
    }

    // Show a loader until FlutterFire is initialized
    if (!_initialized) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      );
    }

    const LatLng _mainLocation = LatLng(25.69893, 32.6421);
    return Scaffold(
      drawer: const EnsoDrawer(),
      appBar: AppBar(
        title: const Text('Was möchtest du ausleihen?:'),
        backgroundColor: Colors.green[700],
      ),
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
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
      ),
    );
  }

  Text getMainText() {
    return Text('Tippe auf den Gegenstand, den du gerne ausleihen möchtest:',
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
            fontSize: 16));
  }
}

Future<bool> hasInternetConnection() async {
  final ConnectivityResult result = await Connectivity().checkConnectivity();
  if (result == ConnectivityResult.mobile) {
    log("Internet connection is from Mobile data");
    return Future.value(true);
  } else if (result == ConnectivityResult.wifi) {
    log("internet connection is from wifi");
    return Future.value(true);
  } else if (result == ConnectivityResult.ethernet) {
    log("internet connection is from wired cable");
    return Future.value(true);
  } else if (result == ConnectivityResult.bluetooth) {
    log("internet connection is from bluethooth threatening");
    return Future.value(true);
  } else if (result == ConnectivityResult.none) {
    log("No internet connection");
    return Future.value(false);
  } else {
    log("Probably no internet connection?");
    return Future.value(false);
  }
}
