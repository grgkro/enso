import 'dart:developer';

import 'package:ensobox/widgets/box_list.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'models/locations.dart' as locations;

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
    var ensoBoxes = await locations.getBoxLocations();
    setState(() {
      _markers.clear();
      for (final box in ensoBoxes.boxes) {
        log(box.id);
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
        title: const Text('Verleihboxen in deiner Nähe:'),
        backgroundColor: Colors.green[700],
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            width:
                MediaQuery.of(context).size.width, // or use fixed size like 200
            height: MediaQuery.of(context).size.height / 2,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(48.7553846205735, 9.172653858386855),
                zoom: 14,
              ),
              markers: _markers.values.toSet(),
            ),
          ),
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
}
