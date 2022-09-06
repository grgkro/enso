import 'dart:developer';
import 'dart:convert';
import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:camera/camera.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ensobox/widgets/auth/verification_overview_screen.dart';
import 'package:ensobox/widgets/enso_drawer.dart';
import 'package:ensobox/widgets/firestore_repository/functions_repo.dart';
import 'package:ensobox/widgets/map_item_overview_screen.dart';
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

DatabaseRepo _databaseRepo = getIt<DatabaseRepo>();
GlobalService _globalService = getIt<GlobalService>();
final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
FunctionsRepo _functionsRepo = getIt<FunctionsRepo>();
AuthRepo _authRepo = getIt<AuthRepo>();

//TODO: https://firebase.google.com/docs/firestore/quickstart#dart  Optional: Improve iOS & macOS build times by including the pre-compiled framework for Firestore
void main() async {
  // Ensure that plugin services are initialized so that `availableCameras()` can be called before `runApp()`
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
          UserIdDetailsScreen.routeName: (ctx) => UserIdDetailsScreen(),
          VerificationOverviewScreen.routeName: (ctx) => VerificationOverviewScreen(),
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
  var subscription;
  var connectionStatus;

  bool _initialized = false;
  bool _error = false;

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _globalService.firebaseAuth = FirebaseAuth.instance;
      _globalService.firebaseAuth.setLanguageCode("de");

      _globalService.isFirebaseInitialized = true;
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      setState(() {
        _error = true;
      });
    }

    // try {
    //   final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
    //     email: 'grgkro@gmail.com',
    //     password: 'password1234',
    //   );
    // } on FirebaseAuthException catch (e) {
    //   if (e.code == 'weak-password') {
    //     print('The password provided is too weak.');
    //   } else if (e.code == 'email-already-in-use') {
    //     print('The account already exists for that email.');
    //   }
    // } catch (e) {
    //   print(e);
    // }
    //
    // await FirebaseAuth.instance.verifyPhoneNumber(
    //   phoneNumber: '+49 151 264 483 12',
    //   verificationCompleted: (PhoneAuthCredential credential) async {
    //     await _firebaseAuth.currentUser!.linkWithCredential(credential);
    //   },
    //   verificationFailed: (FirebaseAuthException e) { print(e.toString());},
    //   codeSent: (String verificationId, int? resendToken) async {
    //     // Update the UI - wait for the user to enter the SMS code
    //     String smsCode = '123456';
    //
    //     // Create a PhoneAuthCredential with the code
    //     PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
    //
    //     // Sign the user in (or link) with the credential
    //     await _firebaseAuth.currentUser!.linkWithCredential(credential);
    //   },
    //   codeAutoRetrievalTimeout: (String verificationId) {},
    // );
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

    getAvailableCameras();
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
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'WLAN AKTIVIEREN',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            AppSettings.openWIFISettings();
          },
        ),
      ));
    } else {
      log("device has internet");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show error message if initialization failed
    if (_error) {
      return Scaffold(
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
      );
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

    return Builder(
      builder: (BuildContext context) {
        return Scaffold(
          drawer: const EnsoDrawer(),
          appBar: AppBar(
            title: const Text('Was möchtest du ausleihen?:'),
            backgroundColor: Colors.green[700],
          ),
          resizeToAvoidBottomInset: false,
          body: const MapItemOverviewScreen(),
        );
      },
    );
  }

  void getAvailableCameras() async {
    log('Going to retrieve the available cameras');
    final List<CameraDescription> cameras = await availableCameras();
    _globalService.cameras = cameras;
    log('Retrieved the available cameras, the device has ${cameras.length} different cameras.');
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
