import 'dart:developer';
import 'dart:io';

import 'package:ensobox/widgets/user_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:pay/pay.dart';

const _paymentItems = [
  PaymentItem(
    label: 'Total',
    amount: '1.00',
    status: PaymentItemStatus.final_price,
  )
];

class Pay extends StatelessWidget {
  const Pay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void showUserDetailsScreen(BuildContext ctx, dynamic paymentResult) {
      Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
        return UserDetailsScreen(paymentResult);
      }));
    }

    // In your Stateless Widget class or State
    void onGooglePayResult(paymentResult) {
      log('Google Pay selected' + paymentResult.toString());

      showUserDetailsScreen(context, paymentResult);
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
}
