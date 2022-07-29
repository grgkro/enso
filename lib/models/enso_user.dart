import 'package:ensobox/models/billing_address.dart';
import 'package:flutter/cupertino.dart';

class EnsoUserBuilder {
  String? id;

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

  // additional (email and phone verified maybe not needed)
  bool idUploaded = false;
  bool idApproved = false;
  String? phone;
  bool emailVerified = false;
  bool phoneVerified = false;
}

class EnsoUser with ChangeNotifier {
  String? id;
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

  bool idUploaded = false;
  bool idApproved = false;
  String? phone;
  bool emailVerified = false;
  bool phoneVerified = false;

  int selfieRandomNumber = 0;

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

    idUploaded = builder.idUploaded;
    idApproved = builder.idApproved;
    phone = builder.phone;
    emailVerified = builder.emailVerified;
    phoneVerified = builder.emailVerified;
  }

  void uploadPhoto() {}
}
