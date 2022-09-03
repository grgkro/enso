import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:ensobox/models/enso_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/otp_form.dart';
import '../provider/current_user_provider.dart';

class GlobalService {
  bool isFirebaseInitialized = false;
  bool isComingFromTakePictureScreen = false;
  String phoneAuthVerificationId = "";
  int? resendToken;
  User? currentAuthUser;
  EnsoUser currentEnsoUser = EnsoUser(EnsoUserBuilder());
  bool isSignedIn = false;
  List<CameraDescription>? cameras;

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
    final prefs = await SharedPreferences.getInstance();

    // If it doesn't exist, returns null.
    return prefs.getString(key);
  }

  Future<String?> saveStringToSharedPref(String key) async {
    final prefs = await SharedPreferences.getInstance();
    // If it doesn't exist, returns null.
    return prefs.getString(key);
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
}
