import 'dart:developer';

import 'package:ensobox/widgets/auth/verification_overview_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../constants/constants.dart' as Constants;
import '../firebase_repository/auth_repo.dart';
import '../firestore_repository/functions_repo.dart';
import '../service_locator.dart';
import '../services/global_service.dart';

GlobalService _globalService = getIt<GlobalService>();
FunctionsRepo _functionsRepo = getIt<FunctionsRepo>();

class EmailAuthForm extends StatefulWidget {
  EmailAuthForm({Key? key}) : super(key: key);

  @override
  _EmailAuthFormState createState() => _EmailAuthFormState();
}

class _EmailAuthFormState extends State<EmailAuthForm> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController =
      TextEditingController(text: "grgk.ro@gmail.com");
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
                Padding(padding: EdgeInsets.only(bottom: size.height * 0.05)),
                !isLoading
                    ? SizedBox(
                        width: size.width * 0.8,
                        child: OutlinedButton(
                          onPressed: () async {
                            //TODO: validate email
                            log("got ${emailController.text}");

                            final SharedPreferences prefs =
                                await SharedPreferences.getInstance();

                            String password = generateRandPassword();

                            final AuthCredential emailCredential =
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
                                final PhoneAuthCredential phoneCredential =
                                    PhoneAuthProvider.credential(
                                        verificationId: verificationId,
                                        smsCode: smsCode);

                                if (_auth.currentUser == null) {
                                  await _auth
                                      .signInWithCredential(phoneCredential);
                                }

                                await _auth.currentUser
                                    ?.linkWithCredential(emailCredential)
                                    .then((UserCredential value) async {
                                  log('linked email to existing account');

                                  _globalService.hasTriggeredConfirmationSms = true;

                                  if (value.user != null &&
                                      value.user!.uid != null) {
                                    final bool hasSendEmail =
                                        await _functionsRepo
                                            .sendVerificationEmail(
                                                value.user?.uid, emailController.text,);
                                    if (hasSendEmail) {
                                      showOpenMailAppSnack(context);
                                    }
                                  }

                                  _globalService.showScreen(context,
                                      VerificationOverviewScreen());
                                });
                              } else {
                                log("Could not link phone to email as the smsCode from shared Preferences was null.");
                                _globalService.isEmailVerified = false;
                                UserCredential userCredentials =
                                    await registerService
                                        .registerByEmailAndHiddenPW(
                                            emailController.text);
                                if (userCredentials.user != null &&
                                    userCredentials.user!.uid != null) {
                                    final bool hasSendEmail =
                                    await _functionsRepo
                                        .sendVerificationEmail(
                                    userCredentials.user?.uid, emailController.text,);
                                    if (hasSendEmail) {
                                      showOpenMailAppSnack(context);
                                    }
                                  }
                                }

                            } catch (e) {
                              log('Error while signing in with phone and link email: ${e.toString()}');
                              _globalService.isEmailVerified = false;
                              try {
                                UserCredential userCredentials =
                                await registerService
                                    .registerByEmailAndHiddenPW(
                                    emailController.text);
                                if (userCredentials.user != null &&
                                    userCredentials.user!.uid != null) {
                                  final bool hasSendEmail =
                                  await _functionsRepo
                                      .sendVerificationEmail(
                                      userCredentials.user?.uid, emailController.text,);
                                  if (hasSendEmail) {
                                    showOpenMailAppSnack(context);
                                  }
                                }

                              } catch (e) {
                                // TODO: what to do if this fails? ErrorScreen
                                log('Error while signing in with email: ${e.toString()}');
                              }
                            }

                            prefs.setString(
                                Constants.emailKey, emailController.text);
                            prefs.setString(
                                Constants.emailPasswordKey, password);

                            _globalService.showScreen(
                                context, VerificationOverviewScreen());
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

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
      showOpenMailAppSnack(BuildContext context) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text("Email zur Bestätigung gesendet, bitte bestätigen."),
      duration: const Duration(seconds: 5),
      action: SnackBarAction(
        label: 'Mail App öffnen',
        onPressed: () async {
          OpenMailAppResult result = await OpenMailApp.openMailApp();

          // If no mail apps found, show error
          if (!result.didOpen && !result.canOpen) {
            showNoMailAppsDialog(context);

            // iOS: if multiple mail apps found, show dialog to select.
            // There is no native intent/default app system in iOS so
            // you have to do it yourself.
          } else if (!result.didOpen && result.canOpen) {
            showDialog(
              context: context,
              builder: (_) {
                return MailAppPickerDialog(
                  mailApps: result.options,
                );
              },
            );
          }
        },
      ),
    ));
  }

  void showNoMailAppsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Open Mail App"),
          content: Text("No mail apps installed"),
          actions: <Widget>[
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }
}
