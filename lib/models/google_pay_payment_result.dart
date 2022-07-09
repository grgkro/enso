import 'package:ensobox/models/payment_method_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'google_pay_payment_result.g.dart';

@JsonSerializable(explicitToJson: true)
class GooglePayPaymentResult {
  GooglePayPaymentResult(
    this.apiVersion,
    this.apiVersionMinor,
    this.paymentMethodData,
    this.type,
  );

  int apiVersion;
  double apiVersionMinor;
  PaymentMethodData? paymentMethodData;

  @JsonKey(defaultValue: "CARD")
  String type;

  factory GooglePayPaymentResult.fromJson(Map<String, dynamic> json) =>
      _$GooglePayPaymentResultFromJson(json);
  Map<String, dynamic> toJson() => _$GooglePayPaymentResultToJson(this);
}
