import 'package:flutter/cupertino.dart';

class EnsoUserBuilder {
  int? id;
  String? address1;
  String? address2;
  String? address3;
  String? email;
  String? administrativeArea;
  String? countryCode;
  String? locality;
  String? name;
  String? phoneNumber;
  int? postalCode;

  // these variables are provided by the MRZ Scanner result
  String? givenNames;
  String? surnames;
  String? countryCodeMrz;
  String? nationalityCountryCode;
  String? documentType;
  String? documentNumber;
  DateTime? birthDate;
  String? sex;
  DateTime? expiryDate;
  String? personalNumber;
  String? personalNumber2;
}

class EnsoUser with ChangeNotifier {
  int? id;
  String? address1;
  String? address2;
  String? address3;
  String? email;
  String? administrativeArea;
  String? countryCode;
  String? locality;
  String? name;
  String? phoneNumber;
  int? postalCode;

  // these variables are provided by the MRZ Scanner result
  String? givenNames;
  String? surnames;
  String? countryCodeMrz;
  String? nationalityCountryCode;
  String? documentType;
  String? documentNumber;
  DateTime? birthDate;
  String? sex;
  DateTime? expiryDate;
  String? personalNumber;
  String? personalNumber2;

  EnsoUser(EnsoUserBuilder builder) {
    id = builder.id;
    address1 = builder.address1;
    address2 = builder.address2;
    address3 = builder.address3;
    email = builder.email;
    administrativeArea = builder.administrativeArea;
    countryCode = builder.countryCode;
    locality = builder.locality;
    name = builder.name;
    phoneNumber = builder.phoneNumber;

    givenNames = builder.givenNames;
    surnames = builder.surnames;
    countryCodeMrz = builder.countryCodeMrz;
    nationalityCountryCode = builder.nationalityCountryCode;
    documentType = builder.documentType;
    documentNumber = builder.documentNumber;
    birthDate = builder.birthDate;
    sex = builder.sex;
    expiryDate = builder.expiryDate;
    personalNumber = builder.personalNumber;
    personalNumber2 = builder.personalNumber2;
  }
}
