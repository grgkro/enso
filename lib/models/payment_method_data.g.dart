// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_method_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentMethodData _$PaymentMethodDataFromJson(Map<String, dynamic> json) =>
    PaymentMethodData(
      json['description'] as String,
      GPayInfo.fromJson(json['info'] as Map<String, dynamic>),
      GPayTokenizationData.fromJson(
          json['tokenizationData'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PaymentMethodDataToJson(PaymentMethodData instance) =>
    <String, dynamic>{
      'description': instance.description,
      'info': instance.info.toJson(),
      'tokenizationData': instance.tokenizationData.toJson(),
    };
