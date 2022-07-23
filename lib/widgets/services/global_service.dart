import 'dart:developer';

import 'package:flutter/material.dart';

import '../auth/otp_form.dart';

class GlobalService {
  bool isComingFromTakePictureScreen = false;
  bool isPhoneVerified = false;
  bool isEmailVerified = false;
  String phoneAuthVerificationId = "";
  int? resendToken;

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
}
