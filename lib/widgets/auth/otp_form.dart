import 'dart:developer';

import 'package:ensobox/widgets/auth/email_auth_form.dart';
import 'package:ensobox/widgets/services/global_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/constants.dart' as Constants;
import '../firebase_repository/auth_repo.dart';
import '../service_locator.dart';

GlobalService _globalService = getIt<GlobalService>();

class OtpForm extends StatefulWidget {
  OtpForm({Key? key}) : super(key: key);

  @override
  _OtpFormState createState() => _OtpFormState();
}

class _OtpFormState extends State<OtpForm> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  //TODO: removed fixed code
  TextEditingController otpController = TextEditingController(text: '123456');
  TextEditingController otpCode = TextEditingController();

  OutlineInputBorder border = OutlineInputBorder(
      borderSide: BorderSide(color: Constants.kBorderColor, width: 3.0));

  bool isLoading = false;

  String? verificationId;

  @override
  void dispose() {
    super.dispose();
    otpController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AuthRepo registerService = getIt<AuthRepo>();

    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Bitte Passcode eingeben"),
          systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.blue),
        ),
        // backgroundColor: Constants.kPrimaryColor,
        body: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: size.width * 0.8,
                  child: TextFormField(
                      keyboardType: TextInputType.phone,
                      controller: otpController,
                      decoration: InputDecoration(
                        labelText: "Passcode",
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 10.0),
                        border: border,
                      )),
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                // SizedBox(
                //   width: size.width * 0.8,
                //   child: TextFormField(
                //     keyboardType: TextInputType.number,
                //     controller: otpCode,
                //     obscureText: true,
                //     decoration: InputDecoration(
                //       labelText: "Enter Otp",
                //       contentPadding: EdgeInsets.symmetric(
                //           vertical: 15.0, horizontal: 10.0),
                //       border: border,
                //       suffixIcon: Padding(
                //         child: Icon(
                //           Icons.add,
                //           size: 15,
                //         ),
                //         padding: EdgeInsets.only(top: 15, left: 15),
                //       ),
                //     ),
                //   ),
                // ),
                Padding(padding: EdgeInsets.only(bottom: size.height * 0.05)),
                !isLoading
                    ? SizedBox(
                        width: size.width * 0.8,
                        child: OutlinedButton(
                          onPressed: () async {
                            log("got ${otpController.text}");

                            final prefs = await SharedPreferences.getInstance();
                            prefs.setString(
                                Constants.smsCodeKey, otpController.text);

                            // Create a PhoneAuthCredential with the code
                            PhoneAuthCredential credential =
                                PhoneAuthProvider.credential(
                                    verificationId:
                                        _globalService.phoneAuthVerificationId,
                                    smsCode: otpController.text);

// Sign the user in (or link) with the credential
// use .onError to handle wrong code, but needs to return Future
                            // TODO: try / catch
                            await _auth
                                .signInWithCredential(credential)
                                .then((value) async {
                              _globalService.currentEnsoUser.hasTriggeredConfirmationSms = true;

                              final prefs =
                                  await SharedPreferences.getInstance();
                              // try {
                              prefs.setBool(Constants.hasTriggeredConfirmationSms, true);
                              _globalService.showScreen(
                                  context, EmailAuthForm());
                              // if the user already signed in with phone & smsCode, we don't want to create a new user but link the email to the existing one
                              // String? email =
                              //     prefs.getString(Constants.emailKey);
                              // String? emailPassword =
                              //     prefs.getString(Constants.emailPasswordKey);
                              //
                              // if (email != null && emailPassword != null) {
                              //   //TODO: replace email & pw with email & Link
                              //   AuthCredential emailCredential =
                              //       EmailAuthProvider.credential(
                              //           email: email,
                              //           password: emailPassword);
                              //
                              //   await _auth.currentUser
                              //       ?.linkWithCredential(emailCredential)
                              //       .then((value) {
                              //     log('linked email to existing account: ${value.user.toString()}');
                              //     _globalService.isEmailVerified = true;
                              //     _globalService.isPhoneVerified = true;
                              //     _globalService.showScreen(context,
                              //         const VerificationOverviewScreen());
                              //   }).onError((error, stackTrace) {
                              //     // TODO: ErrorScreen
                              //     log("Error" + error.toString());
                              //     _globalService.showScreen(context,
                              //         const VerificationOverviewScreen());
                              //   });
                              // } else {
                              //   log("Could not link email to phone as the email or emailPW from shared Preferences was null. Going to just sign in with phone");
                              // }
                              // } catch (e) {
                              //   log('Error while signing in with phone and link email: ${e.toString()}');
                              // }
                            }).onError((error, stackTrace) {
                              log(error.toString());
                              return null;
                            });
                          },
                          child: const Text(Constants.checkOtp),
                          //   style: ButtonStyle(
                          //       // foregroundColor: MaterialStateProperty.all<Color>(
                          //       //     Constants.kPrimaryColor),
                          //       // backgroundColor: MaterialStateProperty.all<Color>(
                          //       //     Constants.kBlackColor),
                          //       side: MaterialStateProperty.all<BorderSide>(
                          //           BorderSide.none)),
                        ),
                      )
                    : const CircularProgressIndicator(),
              ],
            ),
          ),
        ));
  }
}
