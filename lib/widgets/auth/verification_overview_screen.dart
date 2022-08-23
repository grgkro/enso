import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:ensobox/widgets/auth/email_auth_form.dart';
import 'package:ensobox/widgets/auth/phone_auth_form.dart';
import 'package:ensobox/widgets/services/global_service.dart';
import 'package:flutter/material.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/constants.dart';
import '../../models/photo_side.dart';
import '../../models/photo_type.dart';
import '../camera/take_picture_screen.dart';
import '../service_locator.dart';
import '../../constants/constants.dart' as Constants;

GlobalService _globalService = getIt<GlobalService>();
late final SharedPreferences prefs;
bool hasTriggeredConfirmationSms = false;
bool hasTriggeredConfirmationEmail = false;

class VerificationOverviewScreen extends StatefulWidget {

  @override
  State<VerificationOverviewScreen> createState() =>
      _VerificationOverviewScreenState();
}

class _VerificationOverviewScreenState
    extends State<VerificationOverviewScreen> {

  @override
  void initState() {


  }

  void _showCamera() async {
    final List<CameraDescription> cameras = await availableCameras();
    _globalService.cameras = cameras;
    final CameraDescription camera = cameras.first;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => TakePictureScreen(
            camera: camera,
            photoType: PhotoType.id,
            photoSide: PhotoSide.front),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Identität bestätigen:'),
        backgroundColor: Colors.green[700],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          Text(
              "Bevor du die Bohrmaschine ausleihen kannst, benötigen wir folgende Infos von dir:"),

          !hasTriggeredConfirmationSms
              ? ElevatedButton(
                  onPressed:
                      // TODO: was wenn app geschlossen wird und neu angefangen wird? isEmailVerified muss auch in user oder sharedPref gespeichert werden
                      () => showAddPhoneScreen(context),
                  child: Text('Handynummer & Email hinzufügen'),
                )
              : hasTriggeredConfirmationSms &&
                      !hasTriggeredConfirmationEmail
                  ? ElevatedButton(
                      onPressed: () =>
                          _globalService.showScreen(context, EmailAuthForm()),
                      child: const Text('Email hinzufügen'),
                    )
                  : ElevatedButton(
                      onPressed: () => showAddPhoneScreen(context),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green, // background (button) color
                        onPrimary: Colors.white, // foreground (text) color
                      ),
                      child: const Text('Handynummer oder Email ändern'),
                    ),
          ElevatedButton(
            onPressed: !isIdFrontAdded()
                ? startAddingIdFront
                : !isIdFrontAdded()
                    ? startAddingIdBack
                    : null,
            child: const Text('Perso oder Pass fotografieren'),
          )
        ],
      ),
    );
  }

  void startAddingIdFront() {
    log("Respond to button perso foto press, going to take front photo");
    if (!mounted) return;
    _showCamera();
  }

  void startAddingIdBack() {
    log("Respond to button perso foto press");
    if (!mounted) return;
    _showCamera();
  }

  bool isPhoneAdded() {
    return true;
  }

  bool isEmailAdded() {
    return false;
  }

  bool isIdFrontAdded() {
    return false;
  }

  bool isIdBackAdded() {
    return false;
  }

  void showAddPhoneScreen(BuildContext context) {
    log("Respond to button Handynummer verifizieren press");
    // showMrzScannerScreen(context);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return PhoneAuthForm();
    }));
  }

  void showAddEmailScreen() {
    log("Respond to button Email verifizieren press");
    // showMrzScannerScreen(context);
  }

  void initPrefs() async {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }

    bool? hasTriggeredConfirmationSmsTmp = prefs.getBool(Constants.hasTriggeredConfirmationSms);
    if (hasTriggeredConfirmationSmsTmp != null) {
      hasTriggeredConfirmationSms = hasTriggeredConfirmationSmsTmp;
    }
    bool? hasTriggeredConfirmationEmailTmp = prefs.getBool(Constants.hasTriggeredConfirmationEmail);
    if (hasTriggeredConfirmationEmailTmp != null) {
      hasTriggeredConfirmationEmail = hasTriggeredConfirmationEmailTmp;
    }
  }


}
