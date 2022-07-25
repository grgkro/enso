import 'dart:async';
import 'dart:developer';

import 'package:ensobox/widgets/auth/email_auth_form.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/constants.dart' as Constants;
import '../../firebase_options.dart';
import '../service_locator.dart';
import '../services/global_service.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
GlobalService _globalService = getIt<GlobalService>();

class AuthRepo {
  Future<void> initialize() async {
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
          _globalService.isPhoneVerified = true;

          _globalService.showScreen(context, EmailAuthForm());
        },
        verificationFailed: (FirebaseAuthException e) {
          // TODO: Display ERROR Message and let user try again
          if (e.code == 'invalid-phone-number') {
            log(level: 1, 'The provided phone number is not valid.');
          }
          log('Error while verifying phone number: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) async {
          final prefs = await SharedPreferences.getInstance();
          prefs.setString(Constants.verificationId, verificationId);

          if (resendToken != null) {
            prefs.setInt(Constants.resendToken, resendToken);
          }
          _globalService.phoneAuthVerificationId = verificationId;
          _globalService.resendToken = resendToken;

          _globalService.showOtpScreen(context);
        },
        timeout: const Duration(seconds: 30),
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-resolution timed out...
          log("codeAutoRetrievelTimeout - phone could not get verified");
          // TODO: Error Screen
        });
  }

  // void registerByEmailAndHiddenPW(
  //     BuildContext context, String email, String password) async {
  void registerByEmailAndHiddenPW(String email) async {
    // TODO use asc for email & link method
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
    // await _auth
    //     .createUserWithEmailAndPassword(
    //       email: email,
    //       password: password,
    //     )
    await _auth
        .sendSignInLinkToEmail(email: email, actionCodeSettings: acs)
        .whenComplete(() => null)
        .catchError(
            (onError) => log('Error sending email verification $onError'))
        .then((value) {
      log('Successfully sent email & hidden pw verification');
      //TODO: replace email & pw with email & Link
      _globalService.isEmailVerified = true;
      // _globalService.showScreen(context, const VerificationOverviewScreen());
    });
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

  Future<bool> signInUserIfPossible() async {
    // TODO: move this lower into the app to avoid long initial loading time
    final prefs = await SharedPreferences.getInstance();
    // If it doesn't exist, returns null.
    String? email = prefs.getString(Constants.emailKey);
    String? emailPassword = prefs.getString(Constants.emailPasswordKey);

    AuthCredential? credential;
    if (email != null && emailPassword != null) {
      credential =
          EmailAuthProvider.credential(email: email, password: emailPassword);
      log("found the user's credentials in shared pref (email & pw)");
    } else {
      String? smsCode = prefs.getString(Constants.smsCodeKey);
      String? identificationId = prefs.getString(Constants.identificationId);
      if (smsCode != null && identificationId != null) {
        credential = PhoneAuthProvider.credential(
            smsCode: smsCode, verificationId: identificationId);
        log("found the user's credentials in shared pref (phone & smsCode)");
      }
    }

    if (credential != null) {
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      log("User is now signed in: ${userCredential.user?.email ?? ''}");
      if (userCredential.user != null) {
        _globalService.currentUser = userCredential.user;
        log("User was registered before and is now signed in: ${userCredential.user?.email ?? ''}");
        _globalService.isPhoneVerified =
            prefs.getBool(Constants.hasVerifiedPhone) ?? false;
        _globalService.isEmailVerified = userCredential.user!.emailVerified;
        return true;
      } else {
        log("Warn: User seems to have been registered before, but could not get signed in because userCredentials.user was null.");
      }
    } else {
      log("Info: User seems to have been registered before, but could not get signed in, because credential was null.");
    }
    return false;
  }
}
