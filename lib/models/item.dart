import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:json_annotation/json_annotation.dart';

part 'item.g.dart';

// flutter pub run build_runner build --delete-conflicting-outputs

@JsonSerializable()
class Item {
  Item({
    required this.name,
    required this.id,
    required this.model,
    required this.owner,
    this.owner_phone,
    this.owner_email,
    this.country,
    this.state,
    this.website,
    this.description1,
    this.description2,
    this.description3,
    this.starting_cost,
    this.price_normal_1,
    this.price_overdraft_1,
    this.price_unit_1,
    this.price_normal_2,
    this.price_overdraft_2,
    this.price_unit_2,
    this.overdraft_hour,
    this.overdraft_minute,
    this.replacement_cost,
    this.available,
    this.reason_unavailability,
    this.active,
    this.item_images,
  });

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
  Map<String, dynamic> toJson() => _$ItemToJson(this);

  final String name;
  final int id;
  final String model;
  final String owner;
  String? owner_phone;
  String? owner_email;
  String? country;
  String? state;
  String? website;
  String? description1;
  String? description2;
  String? description3;
  double? starting_cost;
  double? price_normal_1;
  double? price_overdraft_1;
  String? price_unit_1;
  double? price_normal_2;
  double? price_overdraft_2;
  String? price_unit_2;
  int? overdraft_hour;
  int? overdraft_minute;
  double? replacement_cost;
  bool? available;
  int?
      reason_unavailability; // 0 = rented out, 1 = item broken, 2 = item stolen, 3 = box broken
  bool? active;
  List<String>? item_images;
}

Future<Item> getItem(String assetPath) async {
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
  return Item.fromJson(
    json.decode(
      await rootBundle.loadString(assetPath),
    ),
  );
}
