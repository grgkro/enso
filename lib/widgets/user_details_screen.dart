import 'dart:developer';

import 'package:ensobox/models/google_pay_payment_result.dart';
import 'package:flutter/material.dart';

class UserDetailsScreen extends StatelessWidget {
  GooglePayPaymentResult userGPayResult;

  UserDetailsScreen(this.userGPayResult, {Key? key}) : super(key: key);

  bool isStringPresent(String? input) {
    return input?.isNotEmpty ?? false;
  }

  ListTile createAddressWidget(GooglePayPaymentResult userGPayResult) {
    ListTile resultTile;
    if (!isStringPresent(
        userGPayResult.paymentMethodData.info.billingAddress.address2)) {
      resultTile = new ListTile(
        leading: const Icon(Icons.label),
        title:
            Text(userGPayResult.paymentMethodData.info.billingAddress.address1),
        subtitle: Text(
            '${userGPayResult.paymentMethodData.info.billingAddress.postalCode} ${userGPayResult.paymentMethodData.info.billingAddress.locality} '
            '${userGPayResult.paymentMethodData.info.billingAddress.countryCode}'),
      );
    } else if (isStringPresent(
            userGPayResult.paymentMethodData.info.billingAddress.address2) &&
        !isStringPresent(
            userGPayResult.paymentMethodData.info.billingAddress.address3))
      resultTile = new ListTile(
        leading: const Icon(Icons.label),
        title: Text(
            "${userGPayResult.paymentMethodData.info.billingAddress.address1}, ${userGPayResult.paymentMethodData.info.billingAddress.address2}"),
        subtitle: Text(
            '${userGPayResult.paymentMethodData.info.billingAddress.postalCode} ${userGPayResult.paymentMethodData.info.billingAddress.locality} '
            '${userGPayResult.paymentMethodData.info.billingAddress.countryCode}'),
      );
    else {
      resultTile = new ListTile(
        leading: const Icon(Icons.label),
        title: Text(
            "${userGPayResult.paymentMethodData.info.billingAddress.address1}, ${userGPayResult.paymentMethodData.info.billingAddress.address2}, ${userGPayResult.paymentMethodData.info.billingAddress.address3}"),
        subtitle: Text(
            '${userGPayResult.paymentMethodData.info.billingAddress.postalCode} ${userGPayResult.paymentMethodData.info.billingAddress.locality} '
            '${userGPayResult.paymentMethodData.info.billingAddress.countryCode}'),
      );
    }
    return resultTile;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Bitte Daten prüfen"),
          actions: <Widget>[
            new IconButton(
                icon: const Icon(Icons.save),
                onPressed: () {
                  log("Pressed");
                })
          ],
        ),
        body: new Column(
          children: <Widget>[
            new ListTile(
              leading: const Icon(Icons.person),
              title: Text(
                  userGPayResult.paymentMethodData.info.billingAddress.name),
              subtitle: Text(userGPayResult
                  .paymentMethodData.info.billingAddress.phoneNumber),
            ),
            createAddressWidget(userGPayResult),
            const Divider(
              height: 1.0,
            ),
            new ListTile(
              leading: const Icon(Icons.email),
              title: new TextField(
                decoration: new InputDecoration(
                  hintText: "Email",
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.blue,
                ),
                label: "Zurück"),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.done_all,
                  color: Colors.blue,
                ),
                label: "Daten stimmen"),
          ],
          onTap: (int index) {
            log("Pressed" + index.toString());
          },
        ));
  }
}
