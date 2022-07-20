import 'package:ensobox/models/billing_address.dart';
import 'package:flutter/cupertino.dart';

class EnsoUserBuilder {
  int? id;

  // from Google Pay result
  BillingAddress? billingAddress;
  String? email;

  // from the MRZ Scanner result
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
  String? frontIdPhoto;
  String? backIdPhoto;
}

class EnsoUser with ChangeNotifier {
  int? id;
  BillingAddress? billingAddress;
  String? email;

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
  String? frontIdPhoto;
  String? backIdPhoto;

  EnsoUser(EnsoUserBuilder builder) {
    id = builder.id;
    billingAddress = builder.billingAddress;
    email = builder.email;

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
    frontIdPhoto = builder.frontIdPhoto;
    backIdPhoto = builder.backIdPhoto;
  }

  void uploadPhoto() {}
}
