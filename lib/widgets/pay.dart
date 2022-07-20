import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:ensobox/models/billing_address.dart';
import 'package:ensobox/models/g_pay_info.dart';
import 'package:ensobox/models/g_pay_tokenization_data.dart';
import 'package:ensobox/models/photo_side.dart';
import 'package:ensobox/models/photo_type.dart';
import 'package:ensobox/widgets/id_scanner/mrz_scanner.dart';
import 'package:flutter/material.dart';
import 'package:pay/pay.dart';
import 'package:provider/provider.dart';

import '../models/enso_user.dart';
import '../models/google_pay_payment_result.dart';
import '../models/payment_method_data.dart';
import 'camera/take_picture_screen.dart';
import 'id_scanner/user_id_details_screen.dart';

const _paymentItems = [
  PaymentItem(
    label: 'Total',
    amount: '1.00',
    status: PaymentItemStatus.final_price,
  )
];

class Pay extends StatefulWidget {
  const Pay({Key? key}) : super(key: key);

  @override
  State<Pay> createState() => _PayState();
}

class _PayState extends State<Pay> {
  static GooglePayPaymentResult gPay = new GooglePayPaymentResult.empty();

  @override
  Widget build(BuildContext context) {
    EnsoUser currentUser = Provider.of<EnsoUser>(context, listen: false);

    void showUserDetailsScreen(BuildContext ctx) {
      Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
        return UserIdDetailsScreen();
      }));
    }

    void showMrzScannerScreen(BuildContext ctx) {
      Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
        return const MrzScanner();
      }));
    }

    void _showCamera() async {
      final cameras = await availableCameras();
      final camera = cameras.first;

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TakePictureScreen(
              camera: camera,
              photoType: PhotoType.id,
              photoSide: PhotoSide.front),
        ),
      );

      // setState(() {
      //   _path = result;
      // });
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

      currentUser.billingAddress = billingAddress;

      GPayInfo gPayInfo =
          new GPayInfo(billingAddress, cardDetails, cardNetwork);
      GPayTokenizationData tokenizationData =
          new GPayTokenizationData(token, tokenType);
      PaymentMethodData paymentMethodData =
          new PaymentMethodData(description, gPayInfo, tokenizationData);
      gPay = new GooglePayPaymentResult(
          apiVersion, apiVersionMinor, paymentMethodData, type);

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
                ),
          ElevatedButton(
            onPressed: () {
              log("Respond to button perso press");
              showMrzScannerScreen(context);
            },
            child: Text('Perso oder Pass scannen'),
          ),
          ElevatedButton(
            onPressed: () {
              log("Respond to button perso foto press");
              _showCamera();
            },
            child: Text('Perso oder Pass fotografieren'),
          )
        ],
      ),
    );
  }
}
