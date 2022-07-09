import 'package:json_annotation/json_annotation.dart';

part 'g_pay_tokenization_data.g.dart';

@JsonSerializable()
class GPayTokenizationData {
  GPayTokenizationData(
    this.token,
    this.type,
  );

  String token;
  String type;

  factory GPayTokenizationData.fromJson(Map<String, dynamic> json) =>
      _$GPayTokenizationDataFromJson(json);
  Map<String, dynamic> toJson() => _$GPayTokenizationDataToJson(this);
}
