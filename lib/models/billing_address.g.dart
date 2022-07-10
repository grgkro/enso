// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BillingAddress _$BillingAddressFromJson(Map<String, dynamic> json) =>
    BillingAddress(
      json['address1'] as String,
      json['address2'] as String,
      json['address3'] as String,
      json['administrativeArea'] as String,
      json['countryCode'] as String,
      json['locality'] as String,
      json['name'] as String,
      json['phoneNumber'] as String,
      json['postalCode'] as int,
      json['sortingCode'] as String,
    );

Map<String, dynamic> _$BillingAddressToJson(BillingAddress instance) =>
    <String, dynamic>{
      'address1': instance.address1,
      'address2': instance.address2,
      'address3': instance.address3,
      'administrativeArea': instance.administrativeArea,
      'countryCode': instance.countryCode,
      'locality': instance.locality,
      'name': instance.name,
      'phoneNumber': instance.phoneNumber,
      'postalCode': instance.postalCode,
      'sortingCode': instance.sortingCode,
    };
