import 'dart:developer';

import 'package:ensobox/widgets/id_scanner/user_id_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mrz_scanner/flutter_mrz_scanner.dart';
import 'package:provider/provider.dart';

import '../../models/enso_user.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  bool isParsed = false;
  MRZController? controller;
  EnsoUser? currentUser;

  @override
  Widget build(BuildContext context) {
    EnsoUser user = Provider.of<EnsoUser>(context, listen: false);
    currentUser = user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rückseite Personalausweis scannen'),
      ),
      body: Stack(
        children: <Widget>[
          MRZScanner(
            withOverlay: true,
            onControllerCreated: onControllerCreated,
          ), //Container
          ElevatedButton(
            onPressed: () {
              log("Respond to button press");
              showUserIdDetailsScreen(context);
            },
            child: Text('Daten per Hand eingeben'),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.stopPreview();
    super.dispose();
  }

  void showUserIdDetailsScreen(BuildContext ctx) {
    controller?.stopPreview();
    log("going to showUserIdDetailsScreen");
    Navigator.pushReplacementNamed(ctx, UserIdDetailsScreen.routeName);
    // Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    //   return UserIdDetailsScreen();
    // }));
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
      if (currentUser != null) {
        currentUser!.documentType = result.documentType;
        currentUser!.countryCodeMrz = result.countryCode;
        currentUser!.surnames = result.surnames;
        currentUser!.givenNames = result.givenNames;
        currentUser!.documentNumber = result.documentNumber;
        currentUser!.nationalityCountryCode = result.nationalityCountryCode;
        currentUser!.birthDate = result.birthDate;
        currentUser!.sex = result.sex.toString();
        currentUser!.expiryDate = result.expiryDate;
        currentUser!.personalNumber = result.personalNumber;
        currentUser!.personalNumber2 = result.personalNumber2!;
        log("currentUser got successfully updated--------------");
      }

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
