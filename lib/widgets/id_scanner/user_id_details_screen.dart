import 'dart:developer';

import 'package:ensobox/widgets/id_scanner/user_details_service.dart';
import 'package:ensobox/widgets/user_add_email.dart';
import 'package:flutter/material.dart';

import '../service_locator.dart';

UserDetailsService _userDetailsService = getIt<UserDetailsService>();

class UserIdDetailsScreen extends StatelessWidget {
  UserIdDetailsScreen({Key? key}) : super(key: key);

  bool isStringPresent(String? input) {
    return input?.isNotEmpty ?? false;
  }

  // ListTile createSexWidget(GooglePayPaymentResult userGPayResult) {
  //   ListTile resultTile;
  //   if (!isStringPresent(
  //       userGPayResult.paymentMethodData.info.billingAddress.address2)) {
  //     resultTile = new ListTile(
  //       leading: const Icon(Icons.label),
  //       title:
  //           Text(userGPayResult.paymentMethodData.info.billingAddress.address1),
  //       subtitle: Text(
  //           '${userGPayResult.paymentMethodData.info.billingAddress.postalCode} ${userGPayResult.paymentMethodData.info.billingAddress.locality} '
  //           '${userGPayResult.paymentMethodData.info.billingAddress.countryCode}'),
  //     );
  //   } else if (isStringPresent(
  //           userGPayResult.paymentMethodData.info.billingAddress.address2) &&
  //       !isStringPresent(
  //           userGPayResult.paymentMethodData.info.billingAddress.address3))
  //     resultTile = new ListTile(
  //       leading: const Icon(Icons.label),
  //       title: Text(
  //           "${userGPayResult.paymentMethodData.info.billingAddress.address1}, ${userGPayResult.paymentMethodData.info.billingAddress.address2}"),
  //       subtitle: Text(
  //           '${userGPayResult.paymentMethodData.info.billingAddress.postalCode} ${userGPayResult.paymentMethodData.info.billingAddress.locality} '
  //           '${userGPayResult.paymentMethodData.info.billingAddress.countryCode}'),
  //     );
  //   else {
  //     resultTile = new ListTile(
  //       leading: const Icon(Icons.label),
  //       title: Text(
  //           "${userGPayResult.paymentMethodData.info.billingAddress.address1}, ${userGPayResult.paymentMethodData.info.billingAddress.address2}, ${userGPayResult.paymentMethodData.info.billingAddress.address3}"),
  //       subtitle: Text(
  //           '${userGPayResult.paymentMethodData.info.billingAddress.postalCode} ${userGPayResult.paymentMethodData.info.billingAddress.locality} '
  //           '${userGPayResult.paymentMethodData.info.billingAddress.countryCode}'),
  //     );
  //   }
  //   return resultTile;
  // }

  void showUserAddEmailScreen(BuildContext ctx) {
    log("Pressed continue");
    Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
      return const UserAddEmail();
    }));
  }

  @override
  Widget build(BuildContext context) {
    // _userDetailsService.documentType = result.documentType;
    // _userDetailsService.countryCode = result.countryCode;
    // _userDetailsService.surnames = result.surnames;
    // _userDetailsService.givenNames = result.givenNames;
    // _userDetailsService.documentNumber = result.documentNumber;
    // _userDetailsService.nationalityCountryCode =
    //     result.nationalityCountryCode;
    // _userDetailsService.birthDate = new ListTile(
    //             leading: const Icon(Icons.person),
    //             title: Text(_userDetailsService.surnames),
    //             subtitle: Text(_userDetailsService.givenNames),
    //           ),;
    // _userDetailsService.sex = result.sex as Sex;
    // _userDetailsService.expiryDate = result.expiryDate;
    // _userDetailsService.personalNumber = result.personalNumber;
    // _userDetailsService.personalNumber2 = result.personalNumber2!;

    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Bitte Daten prüfen"),
      ),
      body: new Column(
        children: <Widget>[
          new ListTile(
            leading: const Icon(Icons.person),
            title: Text(_userDetailsService.surnames),
            subtitle: Text(_userDetailsService.givenNames),
          ),
          new ListTile(
            leading: const Icon(Icons.celebration),
            title:
                Text('Geburtstag: ${_userDetailsService.birthDate.toString()}'),
          ),
          new ListTile(
            leading: const Icon(Icons.info),
            title: Text('Land: ${_userDetailsService.countryCode}'),
            subtitle: Text(
                'Ländercode: ${_userDetailsService.nationalityCountryCode}'),
          ),
          new ListTile(
            leading: const Icon(Icons.info),
            title: Text('Dokument: ${_userDetailsService.documentType}'),
            subtitle: Text(
                'Dokumentennummer: ${_userDetailsService.documentNumber}\nAusweiß Nummer: ${_userDetailsService.personalNumber}'),
          ),
          // createAddressWidget(userGPayResult),
          const Divider(
            height: 1.0,
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
        onTap: (int itemIndex) {
          log("Pressed" + itemIndex.toString());
          switch (itemIndex) {
            case 0:
              Navigator.pop(context);
              break;
            case 1:
              log("Pressed 111" + itemIndex.toString());
              showUserAddEmailScreen(context);
          }
        },
      ),
    );
  }
}
