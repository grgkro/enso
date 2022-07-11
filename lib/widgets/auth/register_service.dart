import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../firebase_options.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class RegisterService {
  Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        print("GOT THE USER ID FROM AUTH: ${user.uid}");
        // obtain shared preferences
        final prefs = await SharedPreferences.getInstance();

        // set value
        await prefs.setString('uid', user.uid);

        // Try reading data from the counter key. If it doesn't exist, return 0.
        final uid = prefs.getString('uid') ?? "";

        log("Got the uid from the store ${uid}");
      }
      print("user WAS NULL???");
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
    FirebaseAuth.instance
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
    FirebaseAuth.instance
        .sendSignInLinkToEmail(email: emailAuth, actionCodeSettings: acs)
        .catchError((onError) =>
            print('Error sending email link verification $onError'))
        .then((value) =>
            print('Successfully sent email verification by email Link'));
  }
}
