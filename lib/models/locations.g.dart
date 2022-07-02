// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locations.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LatLng _$LatLngFromJson(Map<String, dynamic> json) => LatLng(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );

Map<String, dynamic> _$LatLngToJson(LatLng instance) => <String, dynamic>{
      'lat': instance.lat,
      'lng': instance.lng,
    };

Box _$BoxFromJson(Map<String, dynamic> json) => Box(
      address: json['address'] as String,
      service_uuid: json['service_uuid'] as String,
      characteristic_uuid: json['characteristic_uuid'] as String,
      id: json['id'] as String,
      image: json['image'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      name: json['name'] as String,
      owner_phone: json['owner_phone'] as String,
      state: json['state'] as String,
    );

Map<String, dynamic> _$BoxToJson(Box instance) => <String, dynamic>{
      'address': instance.address,
      'service_uuid': instance.service_uuid,
      'characteristic_uuid': instance.characteristic_uuid,
      'id': instance.id,
      'image': instance.image,
      'lat': instance.lat,
      'lng': instance.lng,
      'name': instance.name,
      'owner_phone': instance.owner_phone,
      'state': instance.state,
    };

BoxLocations _$BoxLocationsFromJson(Map<String, dynamic> json) => BoxLocations(
      boxes: (json['boxes'] as List<dynamic>)
          .map((e) => Box.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BoxLocationsToJson(BoxLocations instance) =>
    <String, dynamic>{
      'boxes': instance.boxes,
    };
