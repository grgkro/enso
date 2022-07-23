import 'dart:developer';

import 'package:ensobox/widgets/auth/verification_overview_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../firebase_options.dart';
import '../service_locator.dart';
import '../services/global_service.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
GlobalService _globalService = getIt<GlobalService>();

class AuthRepo {
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    // If it doesn't exist, returns null.
    String? useruid = await prefs.getString('uid');

    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await FirebaseAppCheck.instance.activate(
      webRecaptchaSiteKey: 'recaptcha-v3-site-key',
    );

    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        print("GOT THE USER FROM AUTH: ${user.uid}");
        // set value
        await prefs.setString('uid', user.uid);

        final uid = prefs.getString('uid') ?? "";

        log("Got the uid from the store ${uid}");
      } else {
        print("user WAS NULL???");
      }
    });
  }

  Future<void> verifyPhoneNumber(String number, BuildContext context) async {
    await _auth.verifyPhoneNumber(
        phoneNumber: number,
        verificationCompleted: (PhoneAuthCredential credential) async {
          log("Oh aeyh, verificationCompleted");
          _globalService.showScreen(
              context, const VerificationOverviewScreen());
          ////------------
          // await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            print('The provided phone number is not valid.');
          }
          print('Error while verifying phone number: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) async {
          _globalService.phoneAuthVerificationId = verificationId;
          _globalService.resendToken = resendToken;
          _globalService.showOtpScreen(context);
        },
        timeout: const Duration(seconds: 30),
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-resolution timed out...
          log("Oh no!");
          AuthCredential emailCredential = EmailAuthProvider.credential(
              email: "grg.kro@gmail.com", password: "HorseAsk");
          _auth.currentUser
              ?.linkWithCredential(emailCredential)
              .then((value) => {log(value.user.toString())})
              .onError(
                  (error, stackTrace) => ({log("Error" + error.toString())}));
        });
  }

  void registerByEmailAndHiddenPW(String emailAuth) {
    var acs = ActionCodeSettings(
        // URL you want to redirect back to. The domain (www.example.com) for this
        // URL must be whitelisted in the Firebase Console.
        url: 'https://ensobox.page.link/',
        // This must be true
        handleCodeInApp: true,
        iOSBundleId: 'com.example.ensobox',
        androidPackageName: 'com.example.ensobox',
        // installIfNotAvailable
        androidInstallApp: true,
        // minimumVersion
        androidMinimumVersion: '12');
    _auth
        .createUserWithEmailAndPassword(
          email: emailAuth,
          password: "HorseAsk",
        )
        .catchError(
            (onError) => print('Error sending email verification $onError'))
        .then((value) =>
            print('Successfully sent email & hidden pw verification'));
  }

  void registerByEmailAndLink(String emailAuth) {
    // not working yet
    var acs = ActionCodeSettings(
        // URL you want to redirect back to. The domain (www.example.com) for this
        // URL must be whitelisted in the Firebase Console.
        url: 'https://ensobox.page.link/',
        // This must be true
        handleCodeInApp: true,
        iOSBundleId: 'com.example.ensobox',
        androidPackageName: 'com.example.ensobox',
        // installIfNotAvailable
        androidInstallApp: true,
        // minimumVersion
        androidMinimumVersion: '12');
    _auth
        .sendSignInLinkToEmail(email: emailAuth, actionCodeSettings: acs)
        .catchError((onError) =>
            print('Error sending email link verification $onError'))
        .then((value) =>
            print('Successfully sent email verification by email Link'));
  }
}
