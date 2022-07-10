import 'dart:developer';
import 'dart:io';

import 'package:ensobox/models/billing_address.dart';
import 'package:ensobox/models/g_pay_info.dart';
import 'package:ensobox/models/g_pay_tokenization_data.dart';
import 'package:ensobox/widgets/user_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:pay/pay.dart';
import 'package:provider/provider.dart';

import '../models/google_pay_payment_result.dart';
import '../models/payment_method_data.dart';
import '../models/user.dart';

const _paymentItems = [
  PaymentItem(
    label: 'Total',
    amount: '1.00',
    status: PaymentItemStatus.final_price,
  )
];

class Pay extends StatelessWidget {
  static GooglePayPaymentResult gPay = new GooglePayPaymentResult.empty();

  const Pay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User currentUser = Provider.of<User>(context, listen: false);
    void showUserDetailsScreen(BuildContext ctx) {
      Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
        return UserDetailsScreen();
      }));
    }

    // In your Stateless Widget class or State
    void onGooglePayResult(paymentResult) {
      log("Received result!! ${paymentResult.toString()}");
      Map<String, dynamic> resMap = Map<String, dynamic>.from(paymentResult);
      int apiVersion = resMap['apiVersion'];
      int apiVersionMinor = resMap['apiVersionMinor'];

      Map<String, dynamic> paymentMethodDataMap =
          Map<String, dynamic>.from(resMap['paymentMethodData']);
      String description = paymentMethodDataMap['description'];
      String type = paymentMethodDataMap['type'];

      Map<String, dynamic> infoMap =
          Map<String, dynamic>.from(paymentMethodDataMap['info']);
      String cardDetails = infoMap['cardDetails'];
      String cardNetwork = infoMap['cardNetwork'];

      Map<String, dynamic> tokenizationDataMap =
          Map<String, dynamic>.from(paymentMethodDataMap['tokenizationData']);
      String token = tokenizationDataMap['token'];
      String tokenType = tokenizationDataMap['type'];

      Map<String, dynamic> billingAddressMap =
          Map<String, dynamic>.from(infoMap['billingAddress']);
      String address1 = billingAddressMap['address1'];
      String address2 = billingAddressMap['address2'];
      String address3 = billingAddressMap['address3'];
      String administrativeArea = billingAddressMap['administrativeArea'];
      String countryCode = billingAddressMap['countryCode'].toString();
      String locality = billingAddressMap['locality'];
      String name = billingAddressMap['name'];
      String phoneNumber = billingAddressMap['phoneNumber'];
      int postalCode = int.parse(billingAddressMap['postalCode']);
      String sortingCode = billingAddressMap['sortingCode'];

      BillingAddress billingAddress = new BillingAddress(
          address1,
          address2,
          address3,
          administrativeArea,
          countryCode,
          locality,
          name,
          phoneNumber,
          postalCode,
          sortingCode);

      currentUser = updateCurrentUser(currentUser, billingAddress);

      GPayInfo gPayInfo =
          new GPayInfo(billingAddress, cardDetails, cardNetwork);
      GPayTokenizationData tokenizationData =
          new GPayTokenizationData(token, tokenType);
      PaymentMethodData paymentMethodData =
          new PaymentMethodData(description, gPayInfo, tokenizationData);
      gPay = new GooglePayPaymentResult(
          apiVersion, apiVersionMinor, paymentMethodData, type);

      // currentUser = new User(
      //     0,
      //     billingAddress.address1,
      //     billingAddress.address2,
      //     billingAddress.address3,
      //     "",
      //     billingAddress.administrativeArea,
      //     billingAddress.countryCode,
      //     billingAddress.locality,
      //     billingAddress.name,
      //     billingAddress.phoneNumber,
      //     billingAddress.postalCode);

      log(gPay.paymentMethodData.tokenizationData.token);

      showUserDetailsScreen(context);
      // Send the resulting Google Pay token to your server or PSP
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verleihboxen in deiner Nähe:'),
        backgroundColor: Colors.green[700],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          Platform.isAndroid
              ? GooglePayButton(
                  paymentConfigurationAsset:
                      'sample_payment_configuration.json',
                  paymentItems: _paymentItems,
                  style: GooglePayButtonStyle.black,
                  type: GooglePayButtonType.pay,
                  onPaymentResult: onGooglePayResult,
                )
              : RawApplePayButton(
                  style: ApplePayButtonStyle.black,
                  type: ApplePayButtonType.inStore,
                  onPressed: () {
                    log('Apple Pay selected');
                  },
                )
        ],
      ),
    );
  }

  User updateCurrentUser(User currentUser, BillingAddress billingAddress) {
    currentUser.id = 0;
    currentUser.address1 = billingAddress.address1;
    currentUser.address2 = billingAddress.address2;
    currentUser.address3 = billingAddress.address3;
    currentUser.administrativeArea = billingAddress.administrativeArea;
    currentUser.countryCode = billingAddress.countryCode;
    currentUser.locality = billingAddress.locality;
    currentUser.name = billingAddress.name;
    currentUser.phoneNumber = billingAddress.phoneNumber;
    currentUser.postalCode = billingAddress.postalCode;
    return currentUser;
  }
}
