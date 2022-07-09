import 'dart:convert';
import 'dart:developer';

import 'package:ensobox/models/google_pay_payment_result.dart';
import 'package:flutter/material.dart';

class UserDetailsScreen extends StatelessWidget {
  dynamic paymentResult;

  UserDetailsScreen(this.paymentResult, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String testJson =
        '{"apiVersion": 2, "apiVersionMinor": 0, "paymentMethodData": {"description": "Visa7809", "info": {"billingAddress": {"address1": "Rienzistraße 10", "address2": "", "address3": "", "administrativeArea": "", "countryCode": "DE", "locality": "Stuttgart", "name": "Georg Kromer", "phoneNumber": "+49 1512 6448312", "postalCode": 70597, "sortingCode": ""}, "cardDetails": 7809, "cardNetwork": "VISA"}, "tokenizationData": {"token": "examplePaymentMethodToken", "type": "PAYMENT_GATEWAY"}, "type": "CARD"}}';
    log("testJson" + testJson);
    Map<String, dynamic> resultMap = jsonDecode(testJson);
    log(resultMap.toString());
    var googlePayPaymentResult = GooglePayPaymentResult.fromJson(resultMap);

    if (googlePayPaymentResult.paymentMethodData?.description != null) {
      log(googlePayPaymentResult.paymentMethodData!.description.toString());
      log(googlePayPaymentResult.paymentMethodData!.info.cardDetails
          .toString());
    }
    return Text(paymentResult.toString());
  }
}
