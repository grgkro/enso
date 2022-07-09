import 'package:json_annotation/json_annotation.dart';

part 'billing_address.g.dart';

@JsonSerializable()
class BillingAddress {
  BillingAddress(
    this.address1,
    this.address2,
    this.address3,
    this.administrativeArea,
    this.countryCode,
    this.locality,
    this.name,
    this.phoneNumber,
    this.postalCode,
    this.sortingCode,
  );

  String address1;
  String address2;
  String address3;
  String administrativeArea;
  String countryCode;
  String locality;
  String name;
  String phoneNumber;
  int postalCode;
  String sortingCode;

  factory BillingAddress.fromJson(Map<String, dynamic> json) =>
      _$BillingAddressFromJson(json);
  Map<String, dynamic> toJson() => _$BillingAddressToJson(this);
}
