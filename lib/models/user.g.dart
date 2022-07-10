// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      json['id'] as int,
      json['address1'] as String,
      json['address2'] as String,
      json['address3'] as String,
      json['email'] as String,
      json['administrativeArea'] as String,
      json['countryCode'] as String,
      json['locality'] as String,
      json['name'] as String,
      json['phoneNumber'] as String,
      json['postalCode'] as int,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'address1': instance.address1,
      'address2': instance.address2,
      'address3': instance.address3,
      'email': instance.email,
      'administrativeArea': instance.administrativeArea,
      'countryCode': instance.countryCode,
      'locality': instance.locality,
      'name': instance.name,
      'phoneNumber': instance.phoneNumber,
      'postalCode': instance.postalCode,
    };
