// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'g_pay_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GPayInfo _$GPayInfoFromJson(Map<String, dynamic> json) => GPayInfo(
      BillingAddress.fromJson(json['billingAddress'] as Map<String, dynamic>),
      json['cardDetails'] as String,
      json['cardNetwork'] as String,
    );

Map<String, dynamic> _$GPayInfoToJson(GPayInfo instance) => <String, dynamic>{
      'billingAddress': instance.billingAddress.toJson(),
      'cardDetails': instance.cardDetails,
      'cardNetwork': instance.cardNetwork,
    };
