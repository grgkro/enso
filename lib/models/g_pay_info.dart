import 'package:json_annotation/json_annotation.dart';

import 'billing_address.dart';

part 'g_pay_info.g.dart';

@JsonSerializable(explicitToJson: true)
class GPayInfo {
  GPayInfo.empty();

  GPayInfo(
    this.billingAddress,
    this.cardDetails,
    this.cardNetwork,
  );

  late BillingAddress billingAddress;
  late String cardDetails;
  late String cardNetwork;

  factory GPayInfo.fromJson(Map<String, dynamic> json) =>
      _$GPayInfoFromJson(json);
  Map<String, dynamic> toJson() => _$GPayInfoToJson(this);
}
