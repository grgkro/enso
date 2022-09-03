import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ensobox/widgets/auth/email_auth_form.dart';
import 'package:ensobox/widgets/firebase_repository/rental_repo.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/constants.dart' as Constants;
import '../../firebase_options.dart';
import '../../models/enso_user.dart';
import '../../models/rental.dart';
import '../firestore_repository/database_repo.dart';
import '../provider/current_user_provider.dart';
import '../service_locator.dart';
import '../services/global_service.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
GlobalService _globalService = getIt<GlobalService>();
RentalRepo _rentalRepo = getIt<RentalRepo>();
DatabaseRepo _databaseRepo = getIt<DatabaseRepo>();

class AuthRepo {
  Future<void> initialize() async {
    log("THE INITIALIZE() FUNC HAS BEEN CALLED IN AUTHREPO - shouldn't happen");
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
        _globalService.currentAuthUser = user;
      } else {
        print("user WAS NULL???");
      }
    });
  }

  Future<void> verifyPhoneNumber(String number, BuildContext context) async {
    final currentUserProvider =
    Provider.of<CurrentUserProvider>(context, listen: false);
    EnsoUser currentEnsoUser = currentUserProvider.currentEnsoUser;

    await _auth.verifyPhoneNumber(
        phoneNumber: number,
        verificationCompleted: (PhoneAuthCredential credential) async {
          log("Oh yeah, verificationCompleted");

          EnsoUser user = await _databaseRepo.getUserFromDB(currentEnsoUser.id!);
          user.phoneVerified = true;
          currentUserProvider
              .setCurrentEnsoUser(currentEnsoUser);
          _databaseRepo.updateUser(user);

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
          final SharedPreferences prefs = await SharedPreferences.getInstance();
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

  Future<UserCredential> registerByEmailAndHiddenPW(String email) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String pw = "password";
    // If it doesn't exist, returns null.
    prefs.setString(Constants.emailKey, email);
    prefs.setString(Constants.emailPasswordKey, pw);
    // TODO use asc for email & link method
    // ActionCodeSettings acs = ActionCodeSettings(
    //     // URL you want to redirect back to. The domain (www.example.com) for this
    //     // URL must be whitelisted in the Firebase Console.
    //     url: 'https://ensobox.page.link/',
    //     // This must be true
    //     handleCodeInApp: true,
    //     iOSBundleId: 'com.example.ensobox',
    //     androidPackageName: 'com.example.ensobox',
    //     // installIfNotAvailable
    //     androidInstallApp: true,
    //     // minimumVersion
    //     androidMinimumVersion: '12');
    return _auth
        .createUserWithEmailAndPassword(
      email: email,
      password: 'password',
    );
    // .then(
    //     (UserCredential value) {
    //       log(
    //           'Successfully sent email & hidden pw verification. Returned value: $value');
    //       //TODO: replace email & pw with email & Link
    //       // _globalService.isEmailVerified = true;
    //       // saveUserToFirestore(value);
    //       //   // _globalService.showScreen(context, const VerificationOverviewScreen());
    //     });
    // await _auth
    //     .sendSignInLinkToEmail(email: email, actionCodeSettings: acs)
    //     .whenComplete(() => null)
    //     .catchError(
    //         (onError) => log('Error sending email verification $onError'))
    //     .then((value) {
    //   log('Successfully sent email & hidden pw verification');
    //   //TODO: replace email & pw with email & Link
    //   _globalService.isEmailVerified = true;
    //   saveUserToFirestore()
    //   // _globalService.showScreen(context, const VerificationOverviewScreen());
    // });
  }

  void registerByEmailAndLink(String emailAuth) {
    // not working yet
    final ActionCodeSettings acs = ActionCodeSettings(
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
        .then((value) async {
      print('Successfully sent email verification by email Link');
      AuthCredential credential = EmailAuthProvider.credential(
          email: emailAuth, password: "emailPassword");
      await _auth.currentUser?.linkWithCredential(credential).then((
          UserCredential value) {
        log('linked email to existing account');
      });
    });
  }

  Future<void> saveUserToFirestore(EnsoUser user) async {
    // Create a new user with a first and last name
    final Map<String, dynamic> mappedUser = <String, dynamic>{
      "id": user.id,
      "billingAddress": user.billingAddress,
      "givenNames": user.givenNames,
      "surnames": user.surnames,
      "countryCodeMrz": user.countryCodeMrz,
      "nationalityCountryCode": user.nationalityCountryCode,
      "documentType": user.documentType,
      "documentNumber": user.documentNumber,
      "birthDate": user.birthDate,
      "sex": user.sex,
      "expiryDate": user.expiryDate,
      "personalNumber": user.personalNumber,
      "personalNumber2": user.personalNumber2,
      "frontIdPhotoUrl": user.frontIdPhotoUrl,
      "frontIdPhotoPath": user.frontIdPhotoPath,
      "backIdPhotoUrl": user.backIdPhotoUrl,
      "backIdPhotoPath": user.backIdPhotoPath,
      "selfiePhotoUrl": user.selfiePhotoUrl,
      "selfiePhotoPath": user.selfiePhotoPath,
      "idUploaded": user.idUploaded,
      "idApproved": user.idApproved,
      "emailVerified": user.emailVerified,
      "phoneVerified": user.phoneVerified,
      "selfieRandomNumber": user.selfieRandomNumber,
    };

    FirebaseFirestore db = FirebaseFirestore.instance;
    await db.collection('users').doc(user.id).set(mappedUser);

    print('DocumentSnapshot added with new ID: ${user.id}');

    final Rental testRental = await _rentalRepo.getRental(user.id!);
    final Map<String, dynamic> mappedRental = <String, dynamic>{
      "id": testRental.id,
      "userId": testRental.userId,
      "itemId": testRental.itemId,
      "start": testRental.start,
      "end": testRental.end,
      "totalCost": testRental.totalCost,
      "currency": testRental.currency.toString(),
      "isPayed": testRental.isPayed,
      "dueDate": testRental.dueDate,
      "notedDamages": testRental.notedDamages,
      "damageImagesPaths": testRental.damageImagesPaths,
      "endImagesPaths": testRental.endImagesPaths,
    };
    await db.collection('rentals').doc(testRental.id).set(mappedRental);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .collection("rentals")
        .add(mappedRental);

    await db
        .collection("users")
        .doc(user.id)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> event) {
      // for (var doc in event.docs) {
      print("------------RESPONSE:");
      print("${event.id} => ${event.data()}");
      // }
    });

    await db
        .collection("rentals")
        .doc(testRental.id)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> event) {
      // for (var doc in event.docs) {
      print("------------RESPONSE for RENTAL:");
      print("${event.id} => ${event.data()}");
      // }
    });

    await db
        .collection('users')
        .doc(user.id)
        .collection("rentals")
        .doc(testRental.id)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> event) {
      // for (var doc in event.docs) {
      print("------------RESPONSE for Users RENTAL:");
      print("${event.id} => ${event.data()}");
      // }
    });
  }

  Future<UserCredential?> signInAuthUserIfPossible() async {
    UserCredential? userCredential;
    AuthCredential? authCredential = await getUserCredentialsFromSharedPrefs();
    if (authCredential == null) {
      return Future.error("Info: user could not be signed in, no user credentials found in sharedPrefs.");
    } else {
      try {
        userCredential = await _auth.signInWithCredential(authCredential);
        log("AuthUser is now signed in - email: ${userCredential.user?.email ?? ''} - phone: ${userCredential.user?.phoneNumber ?? ''}");
        return userCredential;
      } catch (e) {
        // e.g. the email was badly formatted: "grgk@gmail.com " (with space at the end...)
        //TODO: show SNACK
        return Future.error("Error signing in User. ${e.toString()}");
      }

    }
  }

  Future<AuthCredential?> getUserCredentialsFromSharedPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
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
    return credential;
  }

  void getUserFromFirebase(String userId) {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    final docRef = db.collection("users").doc(userId);
    docRef.get().then(
          (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        log("current User has idApproved: ${data['idApproved']}");
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }


  clearSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}
