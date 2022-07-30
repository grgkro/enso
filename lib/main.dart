import 'dart:developer';

import 'package:ensobox/providers/boxes.dart';
import 'package:ensobox/providers/users.dart';
import 'package:ensobox/widgets/auth/success_screen.dart';
import 'package:ensobox/widgets/box_list.dart';
import 'package:ensobox/widgets/camera/selfie_explanation_screen.dart';
import 'package:ensobox/widgets/firebase_repository/auth_repo.dart';
import 'package:ensobox/widgets/globals/enso_divider.dart';
import 'package:ensobox/widgets/id_scanner/mrz_scanner.dart';
import 'package:ensobox/widgets/id_scanner/user_id_details_screen.dart';
import 'package:ensobox/widgets/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'models/enso_user.dart';
import 'models/locations.dart' as locations;

void main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  setupServiceLocator(); // This will register any services you have with GetIt before the widget tree gets built.
  AuthRepo registerService = getIt<AuthRepo>();
  await registerService.initialize();
  registerService.registerByEmailAndHiddenPW("grgkr.o@gmail.com");

  try {
    await registerService.signInUserIfPossible();
  } catch (e) {
    log("Could not sign in User at start of the app: ${e.toString()}");
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          // all child widgets of MyApp widget can now listen for changes in Boxes
          create: (ctx) => Boxes(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => EnsoUser(EnsoUserBuilder()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Users(),
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
        // home: Home(),
        home: SelfieExplanationScreen(),
        // initialRoute: '/', // When using initialRoute, don’t define a home property.
        routes: {
          SuccessScreen.routeName: (ctx) => SuccessScreen(),
          MrzScanner.routeName: (ctx) => MrzScanner(),
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
    return Scaffold(
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
