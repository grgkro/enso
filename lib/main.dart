import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'src/locations.dart' as locations;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<Home> {
  final Map<String, Marker> _markers = {};
  Future<void> _onMapCreated(GoogleMapController controller) async {
    final ensoBoxes = await locations.getBoxLocations();
    setState(() {
      _markers.clear();
      for (final box in ensoBoxes.boxes) {
        final marker = Marker(
          markerId: MarkerId(box.name),
          position: LatLng(box.lat, box.lng),
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
        title: const Text('Enso Box Locations'),
        backgroundColor: Colors.green[700],
      ),
      body: Column(children: <Widget>[
        SizedBox(
          // width: 200,
          // height: 200,
          width:
              MediaQuery.of(context).size.width, // or use fixed size like 200
          height: MediaQuery.of(context).size.height - 106,
          child: GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(48.7553846205735, 9.172653858386855),
              zoom: 15,
            ),
            markers: _markers.values.toSet(),
          ),
        ),
        Container(
          child: Card(
            child: Text('Hello'),
          ),
        ),
      ]),
    );
  }
}
