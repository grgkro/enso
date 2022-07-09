import 'package:json_annotation/json_annotation.dart';

import 'billing_address.dart';

part 'g_pay_info.g.dart';

@JsonSerializable(explicitToJson: true)
class GPayInfo {
  GPayInfo(
    this.billingAddress,
    this.cardDetails,
    this.cardNetwork,
  );

  BillingAddress billingAddress;
  int cardDetails;
  String cardNetwork;

  factory GPayInfo.fromJson(Map<String, dynamic> json) =>
      _$GPayInfoFromJson(json);
  Map<String, dynamic> toJson() => _$GPayInfoToJson(this);
}
