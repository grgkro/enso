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
      name: json['name'] as String,
      id: json['id'] as String,
      service_uuid: json['service_uuid'] as String,
      characteristic_uuid: json['characteristic_uuid'] as String,
      address: json['address'] as String,
      image: json['image'] as String,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      owner_phone: json['owner_phone'] as String?,
      owner_email: json['owner_email'] as String?,
      country: json['country'] as String?,
      state: json['state'] as String?,
      website: json['website'] as String?,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => Item.fromJson(e as Map<String, dynamic>))
          .toList(),
      description1: json['description1'] as String?,
      description2: json['description2'] as String?,
      available: json['available'] as bool?,
      reason_unavailability: json['reason_unavailability'] as int?,
      active: json['active'] as bool?,
    );

Map<String, dynamic> _$BoxToJson(Box instance) => <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'service_uuid': instance.service_uuid,
      'characteristic_uuid': instance.characteristic_uuid,
      'address': instance.address,
      'image': instance.image,
      'lat': instance.lat,
      'lng': instance.lng,
      'owner_phone': instance.owner_phone,
      'owner_email': instance.owner_email,
      'country': instance.country,
      'state': instance.state,
      'website': instance.website,
      'items': instance.items?.map((e) => e.toJson()).toList(),
      'description1': instance.description1,
      'description2': instance.description2,
      'available': instance.available,
      'reason_unavailability': instance.reason_unavailability,
      'active': instance.active,
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
