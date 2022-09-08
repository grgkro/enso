import 'dart:developer';

import 'package:app_settings/app_settings.dart';
import 'package:camera/camera.dart';
import 'package:ensobox/models/enso_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/constants.dart' as Constants;

import '../auth/otp_form.dart';
import '../provider/current_user_provider.dart';

class GlobalService {
  late FirebaseAuth firebaseAuth;
  bool isFirebaseInitialized = false;
  bool isComingFromTakePictureScreen = false;
  String phoneAuthVerificationId = "";
  int? resendToken;
  User? currentAuthUser;
  // EnsoUser currentEnsoUser = EnsoUser(EnsoUserBuilder());
  bool isSignedIn = false;
  List<CameraDescription>? cameras;

  String email = "grgk.ro@gmail.com";
  String phoneNumber = "+4915126448312";
  String otp = "123456";

  bool hasShownEmailAppSnackBar = false;

  String? emailSharedPrefs;

  void showScreen(BuildContext ctx, Widget widget) {
    log("Going to next screen: ${widget.key}");
    Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
      return widget;
    }));
  }

  void showOtpScreen(BuildContext ctx) {
    log("Going to next screen: OtpScreen");
    Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
      return OtpForm();
    }));
  }

  Future<String?> getStringFromSharedPref(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // If it doesn't exist, returns null.
    return prefs.getString(key);
  }

  Future<String?> saveStringToSharedPref(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // If it doesn't exist, returns null.
    return prefs.getString(key);
  }

  Future<bool?> clearPwFromSharedPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // If it doesn't exist, returns null.
    return prefs.remove(Constants.emailPasswordKey);
  }

  String? validateEmail(String? value) {
    String pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = RegExp(pattern);
    if (value == null || value.isEmpty || !regex.hasMatch(value))
      return 'Enter a valid email address';
    else
      return null;
  }


  String? validatePassword(String? value) {
    if (value == null) {
      return 'Bitte Password eingeben, mind. 6 Zeichen';
    }
    RegExp regex =
    // RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
    RegExp(r'^(?=.*?[a-z]).{6,}$'); //mind 1 Kleinbuchst, min 6 Zeichen
    if (value.isEmpty) {
      return 'Bitte Password eingeben, mind. 6 Zeichen';
    } else {
      if (!regex.hasMatch(value)) {
        return 'Password ungültig, bitte mind. 6 Zeichen, davon mind. 1 Kleinbuchstabe';
      } else {
        return null;
      }
    }
  }

  showOpenMailAppSnack(BuildContext context) {
    hasShownEmailAppSnackBar = true;
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text("Email zur Bestätigung gesendet, bitte bestätigen."),
      duration: const Duration(seconds: 7),
      action: SnackBarAction(
        label: 'Email App auswählen',
        onPressed: () async {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          final OpenMailAppResult result = await OpenMailApp.openMailApp();

          // If no mail apps found, show error
          if (!result.didOpen && !result.canOpen) {
            showNoMailAppsDialog(context);

            // iOS: if multiple mail apps found, show dialog to select.
            // There is no native intent/default app system in iOS so
            // you have to do it yourself.
          } else if (!result.didOpen && result.canOpen) {
            showDialog(
              context: context,
              builder: (_) {
                return MailAppPickerDialog(
                  mailApps: result.options,
                );
              },
            );
          }
        },
      ),
    ));
  }

  void showNoMailAppsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Email App öffnen"),
          content: Text("Keine Email App gefunden"),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  void handleFirebaseAuthException(BuildContext context, FirebaseAuthException e) {
    log('handleFirebaseAuthException: ${e.code}\n${e.message}');
    if (e.code == 'provider-already-linked') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Der Account wurde bereits mit dieser Handynummer verlinkt.'),
          duration: Duration(seconds: 5),
      ),);
    } else if (e.code == 'invalid-credential') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Ungültige Anmeldeinformationen.'),
          duration: Duration(seconds: 5),
      ),);
    } else if (e.code == 'credential-already-in-use') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Anmeldeinformationen werden bereits von anderem Account benutzt.'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Admins informieren',
            onPressed: () {
              informAdmins(context, e);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          )
      ),);
    } else if (e.code == 'email-already-in-use') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Email existiert bereits. Bitte andere Email eingeben.'),
          duration: Duration(seconds: 5),
      ),);
    } else if (e.code == 'operation-not-allowed') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Der Nutzer hat nicht die erforderlichen Rechte, um diese Aktion durchzuführen.'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Admins informieren',
            onPressed: () {
              informAdmins(context, e);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          )
      ),);
    } else if (e.code == 'invalid-email') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Ungültige Email.'),
          duration: Duration(seconds: 5),
      ),);
    } else if (e.code == 'invalid-verification-code') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Ungültiger SMS Verifizierungscode.'),
          duration: Duration(seconds: 5),
      ),);
    } else if (e.code == 'weak-password') {
      // sollte nicht passieren, da User PW nicht wählen darf.
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Das Password sollte mind. 6 Zeichen haben, mit halt mind. 1 Zahl und nja 1 - 2 Sonderzeichen wär auch nicht schlecht.'),
        duration: Duration(seconds: 10),
      ),);
      return;
    } else if (e.code == 'user-not-found') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Nutzer mit dieser Email konnte nicht gefunden werden.'),
          duration: Duration(seconds: 10),
      ),);
    } else if (e.code == 'network-request-failed') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Leider hat das nicht geklappt. Du scheinst gerade kein Internet zu haben.'),
        duration: Duration(seconds: 10),
          action: SnackBarAction(
            label: 'WLAN AKTIVIEREN',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              AppSettings.openWIFISettings();
            },
          )
      ),);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Unerwarteter Fehler, bitte später erneut versuchen.'),
          duration: Duration(seconds: 20),
          action: SnackBarAction(
            label: 'Admins informieren',
            onPressed: () {
              informAdmins(context, e);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          )
      ),);
      return;
    }
  }

  void informAdmins(BuildContext context, FirebaseAuthException e) {
    //TODO implement
    log("User wishes to inform admins about error-code: ${e.code} \n error-message: ${e.message}");
  }
}
