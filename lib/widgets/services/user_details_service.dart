enum Sex { none, male, female }

class UserDetailsService {
  // these variables are provided by the MRZ Scanner result
  late String givenNames;
  late String surnames;
  late String countryCode;
  late String nationalityCountryCode;
  late String documentType;
  late String documentNumber;
  late DateTime birthDate;
  late String sex;
  late DateTime expiryDate;
  late String personalNumber;
  late String personalNumber2;
}
