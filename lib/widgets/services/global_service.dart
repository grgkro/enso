import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:ensobox/models/enso_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/otp_form.dart';

class GlobalService {
  bool isComingFromTakePictureScreen = false;
  bool isPhoneVerified = false;
  bool isEmailVerified = false;
  bool isIdApproved = false;
  bool hasTriggeredConfirmtionEmail = false;
  bool hasTriggeredConfirmationSms = false;
  String phoneAuthVerificationId = "";
  int? resendToken;
  User? currentUser;
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
}
