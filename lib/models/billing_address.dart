import 'package:json_annotation/json_annotation.dart';

part 'billing_address.g.dart';

@JsonSerializable()
class BillingAddress {
  BillingAddress.empty();

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

  late String address1;
  late String address2;
  late String address3;
  late String administrativeArea;
  late String countryCode;
  late String locality;
  late String name;
  late String phoneNumber;
  late int postalCode;
  late String sortingCode;

  factory BillingAddress.fromJson(Map<String, dynamic> json) =>
      _$BillingAddressFromJson(json);
  Map<String, dynamic> toJson() => _$BillingAddressToJson(this);
}
