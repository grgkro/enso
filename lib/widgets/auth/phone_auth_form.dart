import 'dart:developer';

import 'package:ensobox/widgets/auth/verification_overview_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/constants.dart' as Constants;
import '../../models/enso_user.dart';
import '../firebase_repository/auth_repo.dart';
import '../firestore_repository/database_repo.dart';
import '../provider/current_user_provider.dart';
import '../service_locator.dart';
import '../services/global_service.dart';
import 'email_auth_form.dart';

GlobalService _globalService = getIt<GlobalService>();
DatabaseRepo _databaseRepo = getIt<DatabaseRepo>();

class PhoneAuthForm extends StatefulWidget {
  PhoneAuthForm({Key? key}) : super(key: key);

  @override
  _PhoneAuthFormState createState() => _PhoneAuthFormState();
}

class _PhoneAuthFormState extends State<PhoneAuthForm> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController phoneNumberController =
      TextEditingController(text: _globalService.phoneNumber);
  TextEditingController otpCode = TextEditingController();

  OutlineInputBorder border = OutlineInputBorder(
      borderSide: BorderSide(color: Constants.kBorderColor, width: 3.0));

  bool isLoading = false;
  bool showProgress = false;
  bool showOtpForm = false;
  String buttonText = Constants.textVerifyPhoneNumber;
  String _verificationId = "";
  int? _resendToken;

  String? verificationId;

  @override
  void dispose() {
    super.dispose();
    phoneNumberController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AuthRepo registerService = getIt<AuthRepo>();

    Size size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          title: Text("Bitte Handynummer eingeben"),
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
                    controller: phoneNumberController,
                    decoration: InputDecoration(
                      labelText: "Handynummer",
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 10.0),
                      border: border,
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                Padding(padding: EdgeInsets.only(bottom: size.height * 0.05)),
                !isLoading
                    ? showProgress
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: size.width * 0.8,
                            child: OutlinedButton(
                              onPressed: () async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setString(Constants.phoneNumberKey,
                                    phoneNumberController.text);

                                if (!showOtpForm) {
                                  await startAddingPhoneNumber(context);
                                } else {
                                  setState(() {
                                    showProgress = true;
                                  });
                                  log("User has entered the otp: ${phoneNumberController.text}");
                                  PhoneAuthCredential credential =
                                      PhoneAuthProvider.credential(
                                          verificationId: _verificationId,
                                          smsCode: phoneNumberController.text);

                                  try {
                                    log("Going to link Phone to existing account.");
                                    await _globalService
                                        .firebaseAuth.currentUser!
                                        .linkWithCredential(credential);

                                    final currentUserProvider =
                                        Provider.of<CurrentUserProvider>(
                                            context,
                                            listen: false);
                                    EnsoUser currentEnsoUser =
                                        currentUserProvider.currentEnsoUser;
                                    currentEnsoUser
                                        .hasTriggeredConfirmationSms = true;
                                    currentUserProvider
                                        .setCurrentEnsoUser(currentEnsoUser);
                                    _databaseRepo.updateUser(currentEnsoUser);
                                    // _globalService.currentEnsoUser.hasTriggeredConfirmationSms = true;

                                    // try {
                                    prefs.setBool(
                                        Constants.hasTriggeredConfirmationSms,
                                        true);
                                    _globalService.showScreen(
                                        context, VerificationOverviewScreen());
                                  } on FirebaseAuthException catch (e) {
                                    setState(() {
                                      showProgress = false;
                                    });
                                    _globalService.handleFirebaseAuthException(
                                        context, e);
                                  } catch (e) {
                                    setState(() {
                                      showProgress = false;
                                    });
                                    log(e.toString());
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(e.toString()),
                                        duration: Duration(seconds: 20),
                                      ),
                                    );
                                    // TODO: Show message
                                    return null;
                                  }
                                }

                                // registerService.registerByEmailAndHiddenPW("grg.kro@gmail.com");
                              },
                              child: Text(buttonText),
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

  Future<void> startAddingPhoneNumber(BuildContext context) async {
    setState(() {
      showProgress = true;
    });
    log("got ${phoneNumberController.text}");
    final CurrentUserProvider currentUserProvider =
        Provider.of<CurrentUserProvider>(context, listen: false);
    EnsoUser currentEnsoUser = currentUserProvider.currentEnsoUser;

    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumberController.text,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // ANDROID ONLY! TODO: how to verify on ios?

          log("Oh yeah, verificationCompleted");

          EnsoUser user =
              await _databaseRepo.getUserFromDB(currentEnsoUser.id!);
          user.phoneVerified = true;
          await _globalService.firebaseAuth.currentUser!
              .linkWithCredential(credential);
          currentUserProvider.setCurrentEnsoUser(currentEnsoUser);
          _databaseRepo.updateUser(user);
          setState(() {
            showProgress = false;
          });
          _globalService.showScreen(context, VerificationOverviewScreen());
        },
        verificationFailed: (FirebaseAuthException e) {
          // TODO: Display ERROR Message and let user try again
          if (e.code == 'invalid-phone-number') {
            log(level: 1, 'The provided phone number is not valid.');
          }
          log('Error while verifying phone number: ${e.message}');
          setState(() {
            showProgress = false;
          });
        },
        codeSent: (String verificationId, int? resendToken) async {
          // A resendToken is only supported on Android devices, iOS devices will always return a null value

          buttonText = Constants.submitOtpText;
          phoneNumberController.text = '123456';
          _verificationId = verificationId;
          _resendToken = resendToken;

          setState(() {
            showOtpForm = true;
            showProgress = false;
          });

          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString(Constants.verificationId, verificationId);

          if (resendToken != null) {
            prefs.setInt(Constants.resendToken, resendToken);
          }
          _globalService.phoneAuthVerificationId = verificationId;
          _globalService.resendToken = resendToken;
        },
        timeout: const Duration(seconds: 120),
        codeAutoRetrievalTimeout: (String verificationId) {
          // ANDROID ONLY!
          // Auto-resolution timed out, but can still verified by the user by manually inputting the smsCode.
          log("Auto-resolution timed out... phone could not get verified automatically");
        });
  }
}
