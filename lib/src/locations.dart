import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

part 'locations.g.dart';

@JsonSerializable()
class LatLng {
  LatLng({
    required this.lat,
    required this.lng,
  });

  factory LatLng.fromJson(Map<String, dynamic> json) => _$LatLngFromJson(json);
  Map<String, dynamic> toJson() => _$LatLngToJson(this);

  final double lat;
  final double lng;
}

// @JsonSerializable()
// class Region {
//   Region({
//     // required this.coords,
//     required this.id,
//     required this.name,
//     required this.zoom,
//   });
//
//   factory Region.fromJson(Map<String, dynamic> json) => _$RegionFromJson(json);
//   Map<String, dynamic> toJson() => _$RegionToJson(this);
//
//   // final LatLng coords;
//   final String id;
//   final String name;
//   final double zoom;
// }

@JsonSerializable()
class Box {
  Box({
    required this.address,
    required this.uuid,
    required this.image,
    required this.lat,
    required this.lng,
    required this.name,
    required this.owner_phone,
    required this.state,
  });

  factory Box.fromJson(Map<String, dynamic> json) => _$BoxFromJson(json);
  Map<String, dynamic> toJson() => _$BoxToJson(this);

  final String address;
  final String uuid;
  final String image;
  final double lat;
  final double lng;
  final String name;
  final String owner_phone;
  final String state;
}

@JsonSerializable()
class BoxLocations {
  BoxLocations({
    required this.boxes,
    // required this.regions,
  });

  factory BoxLocations.fromJson(Map<String, dynamic> json) =>
      _$BoxLocationsFromJson(json);
  Map<String, dynamic> toJson() => _$BoxLocationsToJson(this);

  final List<Box> boxes;
  // final List<Region> regions;
}

Future<BoxLocations> getBoxLocations() async {
  const boxLocationsUrl =
      'https://enso-box.s3.eu-central-1.amazonaws.com/boxes.json';

  // Retrieve the locations of Google offices
  try {
    final response = await http.get(Uri.parse(boxLocationsUrl));
    if (response.statusCode == 200) {
      return BoxLocations.fromJson(json.decode(response.body));
    }
  } catch (e) {
    print(e);
  }

  // Fallback for when the above HTTP request fails.
  return BoxLocations.fromJson(
    json.decode(
      await rootBundle.loadString('assets/boxes.json'),
    ),
  );
}
