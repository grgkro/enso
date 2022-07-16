import 'dart:developer';

import 'package:ensobox/widgets/id_scanner/user_details_service.dart';
import 'package:ensobox/widgets/id_scanner/user_id_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mrz_scanner/flutter_mrz_scanner.dart';

import '../service_locator.dart';

UserDetailsService _userDetailsService = getIt<UserDetailsService>();

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  bool isParsed = false;
  MRZController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
      ),
      body: MRZScanner(
        withOverlay: false,
        onControllerCreated: onControllerCreated,
      ),
    );
  }

  @override
  void dispose() {
    controller?.stopPreview();
    super.dispose();
  }

  void showUserIdDetailsScreen(BuildContext ctx) {
    log("going to showUserIdDetailsScreen");
    Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
      return UserIdDetailsScreen();
    }));
  }

  void onControllerCreated(MRZController controller) {
    log("Controller CREATED--------------");
    this.controller = controller;
    controller.onParsed = (result) async {
      if (isParsed) {
        return;
      }
      isParsed = true;
      log("MRZ got successfully parsed--------------");
      _userDetailsService.documentType = result.documentType;
      _userDetailsService.countryCode = result.countryCode;
      _userDetailsService.surnames = result.surnames;
      _userDetailsService.givenNames = result.givenNames;
      _userDetailsService.documentNumber = result.documentNumber;
      _userDetailsService.nationalityCountryCode =
          result.nationalityCountryCode;
      _userDetailsService.birthDate = result.birthDate;
      _userDetailsService.sex = result.sex.toString();
      _userDetailsService.expiryDate = result.expiryDate;
      _userDetailsService.personalNumber = result.personalNumber;
      _userDetailsService.personalNumber2 = result.personalNumber2!;

      showUserIdDetailsScreen(context);
      // await showDialog<void>(
      //     context: context,
      //     builder: (context) => AlertDialog(
      //             content: Column(
      //           mainAxisSize: MainAxisSize.min,
      //           children: <Widget>[
      //             Text('Document type: ${result.documentType}'),
      //             Text('Country: ${result.countryCode}'),
      //             Text('Surnames: ${result.surnames}'),
      //             Text('Given names: ${result.givenNames}'),
      //             Text('Document number: ${result.documentNumber}'),
      //             Text('Nationality code: ${result.nationalityCountryCode}'),
      //             Text('Birthdate: ${result.birthDate}'),
      //             Text('Sex: ${result.sex}'),
      //             Text('Expriy date: ${result.expiryDate}'),
      //             Text('Personal number: ${result.personalNumber}'),
      //             Text('Personal number 2: ${result.personalNumber2}'),
      //             ElevatedButton(
      //               child: const Text('ok'),
      //               onPressed: () {
      //                 isParsed = false;
      //                 return showUserIdDetailsScreen(context);
      //                 ;
      //               },
      //             ),
      //           ],
      //         )));
    };
    controller.onError = (error) => print(error);

    controller.startPreview();
  }
}
