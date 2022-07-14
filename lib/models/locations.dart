import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:json_annotation/json_annotation.dart';

part 'locations.g.dart';

// flutter pub run build_runner build --delete-conflicting-outputs

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
    required this.name,
    required this.id,
    required this.service_uuid,
    required this.characteristic_uuid,
    required this.address,
    required this.image,
    this.lat,
    this.lng,
    this.owner_phone,
    this.owner_email,
    this.country,
    this.state,
    this.website,
    this.item,
    this.description1,
    this.description2,
    this.description3,
    this.price_hour_normal,
    this.price_hour_overdraft,
    this.price_minute,
    this.price_minute_overdraft,
    this.price_km,
    this.overdraft_hour,
    this.overdraft_minute,
    this.replacement_cost,
    this.available,
    this.reason_unavailability,
    this.active,
    this.item_images,
  });

  factory Box.fromJson(Map<String, dynamic> json) => _$BoxFromJson(json);
  Map<String, dynamic> toJson() => _$BoxToJson(this);

  final String name;
  final String id;
  final String service_uuid;
  final String characteristic_uuid;
  final String address;
  final String image;
  double? lat;
  double? lng;
  String? owner_phone;
  String? owner_email;
  String? country;
  String? state;
  String? website;
  String? item;
  String? description1;
  String? description2;
  String? description3;
  double? price_hour_normal;
  double? price_hour_overdraft;
  double? price_minute;
  double? price_minute_overdraft;
  double? price_km;
  int? overdraft_hour;
  int? overdraft_minute;
  double? replacement_cost;
  bool? available;
  int?
      reason_unavailability; // 0 = rented out, 1 = item broken, 2 = item stolen, 3 = box broken
  bool? active;
  List<String>? item_images;
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
  // to load from AWS uncomment this!
  // const boxLocationsUrl =
  //     'https://enso-box.s3.eu-central-1.amazonaws.com/boxes.json';
  //
  // // Retrieve the locations of Google offices
  // try {
  //   final response = await http.get(Uri.parse(boxLocationsUrl));
  //   if (response.statusCode == 200) {
  //     return BoxLocations.fromJson(json.decode(response.body));
  //   }
  // } catch (e) {
  //   print(e);
  // }

  // Fallback for when the above HTTP request fails.
  return BoxLocations.fromJson(
    json.decode(
      await rootBundle.loadString('assets/boxes.json'),
    ),
  );
}
