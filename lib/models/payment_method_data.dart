import 'package:json_annotation/json_annotation.dart';

import 'g_pay_info.dart';
import 'g_pay_tokenization_data.dart';

part 'payment_method_data.g.dart';

@JsonSerializable(explicitToJson: true)
class PaymentMethodData {
  PaymentMethodData(
    this.description,
    this.info,
    this.tokenizationData,
  );

  String description;
  GPayInfo info;
  GPayTokenizationData tokenizationData;

  factory PaymentMethodData.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodDataFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentMethodDataToJson(this);
}
