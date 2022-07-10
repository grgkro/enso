// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'google_pay_payment_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GooglePayPaymentResult _$GooglePayPaymentResultFromJson(
        Map<String, dynamic> json) =>
    GooglePayPaymentResult(
      json['apiVersion'] as int,
      json['apiVersionMinor'] as int,
      PaymentMethodData.fromJson(
          json['paymentMethodData'] as Map<String, dynamic>),
      json['type'] as String? ?? 'CARD',
    );

Map<String, dynamic> _$GooglePayPaymentResultToJson(
        GooglePayPaymentResult instance) =>
    <String, dynamic>{
      'apiVersion': instance.apiVersion,
      'apiVersionMinor': instance.apiVersionMinor,
      'paymentMethodData': instance.paymentMethodData.toJson(),
      'type': instance.type,
    };
