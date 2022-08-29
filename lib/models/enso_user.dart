import 'package:ensobox/models/billing_address.dart';
import 'package:flutter/material.dart';

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
  bool hasTriggeredIdApprovement = false;
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
  String? frontIdPhotoUrl;
  String? frontIdPhotoPath;
  String? backIdPhotoUrl;
  String? backIdPhotoPath;
  String? selfiePhotoUrl;
  String? selfiePhotoPath;

  bool idUploaded = false;
  bool idApproved = false;
  bool hasTriggeredIdApprovement = false;
  String? phone;
  bool emailVerified = false;
  bool hasTriggeredConfirmationEmail = false;
  bool phoneVerified = false;
  bool hasTriggeredConfirmationSms = false;

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
    frontIdPhotoUrl = builder.frontIdPhoto;
    backIdPhotoUrl = builder.backIdPhoto;

    idUploaded = builder.idUploaded;
    idApproved = builder.idApproved;
    phone = builder.phone;
    emailVerified = builder.emailVerified;
    phoneVerified = builder.phoneVerified;
    hasTriggeredIdApprovement = builder.hasTriggeredIdApprovement;
  }

  void uploadPhoto() {}

  EnsoUser.fromData(Map<String, dynamic> data)
      : id = data['uid'],
        email = data['email'],
        hasTriggeredConfirmationEmail = data['hasTriggeredConfirmationEmail'],
        hasTriggeredConfirmationSms = data['hasTriggeredConfirmationSms'],
        hasTriggeredIdApprovement = data['hasTriggeredIdApprovement'],
        idApproved = data['idApproved'];

  // emailVerified = data['emailVerified'];

  Map<String, dynamic> toJson() {
    return {
      'uid': id,
      'email': email,
      'hasTriggeredConfirmationEmail': hasTriggeredConfirmationEmail,
      'hasTriggeredConfirmationSms': hasTriggeredConfirmationSms,
      'hasTriggeredIdApprovement': hasTriggeredIdApprovement,
      'idApproved': idApproved,
    };
  }

  @override
  String toString() {
    return 'EnsoUser{id: $id, billingAddress: $billingAddress, email: $email, givenNames: $givenNames, surnames: $surnames, countryCodeMrz: $countryCodeMrz, nationalityCountryCode: $nationalityCountryCode, documentType: $documentType, documentNumber: $documentNumber, birthDate: $birthDate, sex: $sex, expiryDate: $expiryDate, personalNumber: $personalNumber, personalNumber2: $personalNumber2, frontIdPhotoUrl: $frontIdPhotoUrl, frontIdPhotoPath: $frontIdPhotoPath, backIdPhotoUrl: $backIdPhotoUrl, backIdPhotoPath: $backIdPhotoPath, selfiePhotoUrl: $selfiePhotoUrl, selfiePhotoPath: $selfiePhotoPath, idUploaded: $idUploaded, idApproved: $idApproved, hasTriggeredIdApprovement: $hasTriggeredIdApprovement, phone: $phone, emailVerified: $emailVerified, hasTriggeredConfirmationEmail: $hasTriggeredConfirmationEmail, phoneVerified: $phoneVerified, hasTriggeredConfirmationSms: $hasTriggeredConfirmationSms, selfieRandomNumber: $selfieRandomNumber}';
  }
}
