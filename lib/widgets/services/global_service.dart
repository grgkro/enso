import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:ensobox/models/enso_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  String emailInput = "grgk.ro@gmail.com";

  bool hasShownEmailAppSnackBar = false;

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

  void handleFirebaseAuthException(BuildContext context, FirebaseAuthException e) {
    if (e.code == 'provider-already-linked') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Der Account wurde bereits verlinkt.'),
          duration: Duration(seconds: 20),
      ),);
    } else if (e.code == 'invalid-credential') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Ungültige Anmeldeinformationen.'),
          duration: Duration(seconds: 20),

      ),);
    } else if (e.code == 'credential-already-in-use') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Anmeldeinformationen werden bereits von anderem Account benutzt.'),
          duration: Duration(seconds: 20),
          action: SnackBarAction(
            label: 'Admins informieren',
            onPressed: () {
              informAdmins(context);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          )
      ),);
    } else if (e.code == 'email-already-in-use') {
      log('The account already exists for that email.');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Email existiert bereits. Bitte andere Email eingeben.'),
          duration: Duration(seconds: 20),
      ),);
    } else if (e.code == 'operation-not-allowed') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Der Nutzer hat nicht die erforderlichen Rechte, um diese Aktion durchzuführen.'),
          duration: Duration(seconds: 20),
          action: SnackBarAction(
            label: 'Admins informieren',
            onPressed: () {
              informAdmins(context);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          )
      ),);
    } else if (e.code == 'invalid-email') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Ungültige Email.'),
          duration: Duration(seconds: 20),
      ),);
    } else if (e.code == 'invalid-verification-code') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Ungültiger SMS Verifizierungscode.'),
          duration: Duration(seconds: 5),

      ),);
    } else if (e.code == 'invalid-verification-id') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Ungültige Verifizierungs-ID.'),
          duration: Duration(seconds: 20),
          action: SnackBarAction(
            label: 'Admins informieren',
            onPressed: () {
              // TODO: add Admins informieren?
              informAdmins(context);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          )
      ),);
    } else if (e.code == 'weak-password') {
      log('The password provided is too weak.');
      //TODO: macht keinen Sinn, da User PW nicht wählen darf.
      return;
    } else {
      log('Unexpected FirebaseAuthException: ${e.code}');
      // TODO: Show Snack
      return;
    }
  }

  void informAdmins(BuildContext context) {}
}
