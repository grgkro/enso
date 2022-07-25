import 'dart:developer';

import 'package:ensobox/widgets/id_scanner/mrz_scanner.dart';
import 'package:ensobox/widgets/user_add_email.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/enso_user.dart';
import '../globals/enso_divider.dart';
import '../service_locator.dart';
import '../services/global_service.dart';

GlobalService _globalVariablesService = getIt<GlobalService>();

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

    bool isStringPresent(String? input) {
      return input?.isNotEmpty ?? false;
    }

    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Bitte Daten prüfen"),
      ),
      body: new Column(
        children: generateListTiles(currentUser),

        // createAddressWidget(userGPayResult),
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
              if (_globalVariablesService.isComingFromTakePictureScreen) {
                Navigator.pop(context);
              } else {
                showMrzScanner(context);
              }

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

  List<Widget> generateListTiles(EnsoUser currentUser) {
    List<Widget> result = [];

    ListTile? nameTile = createNameTile(currentUser);
    if (nameTile != null) {
      result.add(nameTile);
    }

    ListTile? birthdayTile = createBirthdayTile(currentUser);
    if (birthdayTile != null) {
      result.add(birthdayTile);
    }

    ListTile? addressTile = createAddressTile(currentUser);
    if (addressTile != null) {
      result.add(addressTile);
    }

    ListTile? countryTile = createCountryTile(currentUser);
    if (countryTile != null) {
      result.add(countryTile);
    }

    // ...

    result.add(
      const EnsoDivider(),
    );

    return result;
  }

  ListTile? createNameTile(EnsoUser currentUser) {
    ListTile? nameTile;

    if (isStringPresent(currentUser.surnames) &&
        isStringPresent(currentUser.givenNames)) {
      nameTile = ListTile(
        leading: const Icon(Icons.person),
        title: Text(
            isStringPresent(currentUser.surnames) ? currentUser.surnames! : ""),
        subtitle: Text(isStringPresent(currentUser.givenNames)
            ? currentUser.givenNames!
            : ""),
      );
    } else if (currentUser.billingAddress != null &&
        isStringPresent(currentUser.billingAddress!.name) &&
        isStringPresent(currentUser.billingAddress!.phoneNumber)) {
      nameTile = ListTile(
        leading: const Icon(Icons.person),
        title: Text(currentUser.billingAddress!.name),
        subtitle: Text(currentUser.billingAddress!.phoneNumber),
      );
    } else {
      nameTile = null;
    }
    return nameTile;
  }

  ListTile? createBirthdayTile(EnsoUser currentUser) {
    ListTile? birthdayTile;

    if (currentUser.birthDate != null &&
        isStringPresent(currentUser.birthDate.toString())) {
      var outputFormat = DateFormat('dd-MM-yyyy');
      var formattedBirthday = outputFormat.format(currentUser.birthDate!);
      birthdayTile = ListTile(
        leading: const Icon(Icons.celebration),
        title: Text('Geburtstag: ${formattedBirthday.toString()}'),
      );
    } else {
      birthdayTile = null;
    }
    return birthdayTile;
  }

  ListTile? createCountryTile(EnsoUser currentUser) {
    ListTile? birthdayTile;

    if (isStringPresent(currentUser.countryCodeMrz) ||
        isStringPresent(currentUser.nationalityCountryCode)) {
      birthdayTile = ListTile(
          leading: const Icon(Icons.info),
          title: Text(
              'Ländercode: ${currentUser.countryCodeMrz ?? currentUser.nationalityCountryCode}'));
    } else if (currentUser.billingAddress != null &&
        isStringPresent(currentUser.billingAddress!.countryCode)) {
      birthdayTile = ListTile(
          leading: const Icon(Icons.info),
          title:
              Text('Ländercode: ${currentUser.billingAddress!.countryCode}'));
    } else {
      birthdayTile = null;
    }
    return birthdayTile;
  }

  ListTile? createAddressTile(EnsoUser currentUser) {
    ListTile? addressTile;
    if (currentUser.billingAddress != null &&
        isStringPresent(currentUser.billingAddress!.address1) &&
        !isStringPresent(currentUser.billingAddress!.address2)) {
      addressTile = ListTile(
        leading: const Icon(Icons.label),
        title: Text(currentUser.billingAddress!.address1),
        subtitle: Text(
            '${currentUser.billingAddress!.postalCode} ${currentUser.billingAddress!.locality}'),
      );
    } else if (currentUser.billingAddress != null &&
        isStringPresent(currentUser.billingAddress!.address1) &&
        isStringPresent(currentUser.billingAddress!.address2)) {
      addressTile = ListTile(
          leading: const Icon(Icons.label),
          title: Text(
              '${currentUser.billingAddress!.address1}, ${currentUser.billingAddress!.address2}'),
          subtitle: Text(
              '${currentUser.billingAddress!.postalCode} ${currentUser.billingAddress!.locality}'));
    } else {
      addressTile = null;
    }
    return addressTile;
  }
}
