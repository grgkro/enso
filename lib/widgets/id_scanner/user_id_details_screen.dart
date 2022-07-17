import 'dart:developer';

import 'package:ensobox/widgets/id_scanner/mrz_scanner.dart';
import 'package:ensobox/widgets/user_add_email.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/enso_user.dart';

class UserIdDetailsScreen extends StatelessWidget {
  static const routeName = '/user-id-details';

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
    EnsoUser currentUser = Provider.of<EnsoUser>(context, listen: false);
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

    bool isStringPresent(String? input) {
      return input?.isNotEmpty ?? false;
    }

    ListTile getBirthdayTile() {
      if (currentUser.birthDate != null) {
        return new ListTile(
          leading: const Icon(Icons.celebration),
          title: Text('Geburtstag: ${currentUser.birthDate!.toString()}'),
        );
      } else {
        return new ListTile(
          leading: const Icon(Icons.celebration),
          title: Text('Geburtstag: ""}'),
        );
      }
    }

    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Bitte Daten prüfen"),
      ),
      body: new Column(
        children: <Widget>[
          new ListTile(
            leading: const Icon(Icons.person),
            title: Text(isStringPresent(currentUser.surnames)
                ? currentUser.surnames!
                : ""),
            subtitle: Text(isStringPresent(currentUser.givenNames)
                ? currentUser.givenNames!
                : ""),
          ),
          getBirthdayTile(),
          new ListTile(
            leading: const Icon(Icons.info),
            title: Text(
                'Land: ${isStringPresent(currentUser.countryCodeMrz) ? currentUser.countryCodeMrz! : ""}'),
            subtitle: Text(
                'Ländercode: ${isStringPresent(currentUser.nationalityCountryCode) ? currentUser.nationalityCountryCode! : ""}'),
          ),
          new ListTile(
            leading: const Icon(Icons.info),
            title: Text(
                'Dokument: ${isStringPresent(currentUser.documentType) ? currentUser.documentType! : ""}'),
            subtitle: Text(
                'Dokumentennummer: ${isStringPresent(currentUser.documentNumber) ? currentUser.documentNumber! : ""}\nAusweiß Nummer: ${isStringPresent(currentUser.personalNumber) ? currentUser.personalNumber! : ""}'),
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
              label: "Kamera"),
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
              // Navigator.pop(context);
              showMrzScanner(context);
              break;
            case 1:
              log("Pressed 111" + itemIndex.toString());
              showUserAddEmailScreen(context);
          }
        },
      ),
    );
  }

  void showMrzScanner(BuildContext ctx) {
    log("going to showUserIdDetailsScreen");
    Navigator.pushReplacementNamed(ctx, MrzScanner.routeName);
    // Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    //   return MrzScanner();
    // }));
  }
}
