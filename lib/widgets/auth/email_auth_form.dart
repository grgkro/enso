import 'dart:developer';

import 'package:ensobox/widgets/auth/verification_overview_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/constants.dart' as Constants;
import '../firebase_repository/auth_repo.dart';
import '../service_locator.dart';
import '../services/global_service.dart';

GlobalService _globalService = getIt<GlobalService>();

class EmailAuthForm extends StatefulWidget {
  EmailAuthForm({Key? key}) : super(key: key);

  @override
  _EmailAuthFormState createState() => _EmailAuthFormState();
}

class _EmailAuthFormState extends State<EmailAuthForm> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController =
      TextEditingController(text: "gr.gkro@gmail.com");
  TextEditingController otpCode = TextEditingController();

  OutlineInputBorder border = OutlineInputBorder(
      borderSide: BorderSide(color: Constants.kBorderColor, width: 3.0));

  bool isLoading = false;

  String? verificationId;

  @override
  Widget build(BuildContext context) {
    AuthRepo registerService = getIt<AuthRepo>();

    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text("Bitte Email eingeben"),
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
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
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
                            //TODO: validate email
                            log("got ${emailController.text}");

                            String password = generateRandPassword();

                            final prefs = await SharedPreferences.getInstance();
                            prefs.setString(
                                Constants.emailKey, emailController.text);
                            prefs.setString(
                                Constants.emailPasswordKey, password);

                            AuthCredential emailCredential =
                                EmailAuthProvider.credential(
                                    email: emailController.text,
                                    password: password);

                            try {
                              // if the user already signed in with phone & smsCode, we don't want to create a new user but link the email to the existing one
                              String? smsCode =
                                  prefs.getString(Constants.smsCodeKey);
                              String? verificationId =
                                  prefs.getString(Constants.verificationId);

                              if (smsCode != null && verificationId != null) {
                                PhoneAuthCredential phoneCredential =
                                    PhoneAuthProvider.credential(
                                        verificationId: verificationId,
                                        smsCode: smsCode);

                                await _auth
                                    .signInWithCredential(phoneCredential);

                                await _auth.currentUser
                                    ?.linkWithCredential(emailCredential)
                                    .then((value) {
                                  log('linked email to existing account');
                                  //TODO: replace email & pw with email & Link
                                  _globalService.isEmailVerified = true;
                                  _globalService.isPhoneVerified = true;
                                  _globalService.showScreen(context,
                                      const VerificationOverviewScreen());
                                });
                              } else {
                                log("Could not link phone to email as the smsCode from shared Preferences was null.");
                                _globalService.isEmailVerified = false;
                                // registerService.registerByEmailAndHiddenPW(
                                //     context, emailController.text, password);
                              }
                            } catch (e) {
                              log('Error while signing in with phone and link email: ${e.toString()}');
                              _globalService.isEmailVerified = false;
                              // try {
                              //   registerService.registerByEmailAndHiddenPW(
                              //       context, emailController.text, password);
                              // } catch (e) {
                              //   // TODO: what to do if this fails? ErrorScreen
                              //   log('Error while signing in with email: ${e.toString()}');
                              // }
                            }
                            _globalService.showScreen(
                                context, const VerificationOverviewScreen());
                          },
                          child: Text(Constants.textSignInEmail),
                          //   style: ButtonStyle(
                          //       // foregroundColor: MaterialStateProperty.all<Color>(
                          //       //     Constants.kPrimaryColor),
                          //       // backgroundColor: MaterialStateProperty.all<Color>(
                          //       //     Constants.kBlackColor),
                          //       side: MaterialStateProperty.all<BorderSide>(
                          //           BorderSide.none)),
                        ),
                      )
                    : CircularProgressIndicator(),
              ],
            ),
          ),
        ));
  }

  String generateRandPassword() {
    // TODO: generate real rand pw instead of HorseAsk
    log("TODO: generate real rand pw instead of HorseAsk");
    return "HorseAsk";
  }
}
