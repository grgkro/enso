import 'package:ensobox/models/payment_method_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'google_pay_payment_result.g.dart';

@JsonSerializable(explicitToJson: true)
class GooglePayPaymentResult {
  GooglePayPaymentResult.empty();

  GooglePayPaymentResult(
    this.apiVersion,
    this.apiVersionMinor,
    this.paymentMethodData,
    this.type,
  );

  late int apiVersion;
  late int apiVersionMinor;
  late PaymentMethodData paymentMethodData;

  @JsonKey(defaultValue: "CARD")
  late String type;

  factory GooglePayPaymentResult.fromJson(Map<String, dynamic> json) =>
      _$GooglePayPaymentResultFromJson(json);
  Map<String, dynamic> toJson() => _$GooglePayPaymentResultToJson(this);
}
