import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User with ChangeNotifier {
  late int _id;
  late String _address1;
  late String _address2;
  late String _address3;
  late String _email;
  late String _administrativeArea;
  late String _countryCode;
  late String _locality;
  late String _name;
  late String _phoneNumber;
  late int _postalCode;

  User.empty();

  User(
    this._id,
    this._address1,
    this._address2,
    this._address3,
    this._email,
    this._administrativeArea,
    this._countryCode,
    this._locality,
    this._name,
    this._phoneNumber,
    this._postalCode,
  );

  int get id => _id;

  set id(int value) {
    _id = value;
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  String get address1 => _address1;

  set address1(String value) {
    _address1 = value;
  }

  String get address2 => _address2;

  set address2(String value) {
    _address2 = value;
  }

  String get address3 => _address3;

  set address3(String value) {
    _address3 = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get administrativeArea => _administrativeArea;

  set administrativeArea(String value) {
    _administrativeArea = value;
  }

  String get countryCode => _countryCode;

  set countryCode(String value) {
    _countryCode = value;
  }

  String get locality => _locality;

  set locality(String value) {
    _locality = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get phoneNumber => _phoneNumber;

  set phoneNumber(String value) {
    _phoneNumber = value;
  }

  int get postalCode => _postalCode;

  set postalCode(int value) {
    _postalCode = value;
  }
}
