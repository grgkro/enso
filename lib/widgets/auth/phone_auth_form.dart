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
      TextEditingController(text: "+4915126448312");
  TextEditingController otpCode = TextEditingController();

  OutlineInputBorder border = OutlineInputBorder(
      borderSide: BorderSide(color: Constants.kBorderColor, width: 3.0));

  bool isLoading = false;
  bool showProgress = false;
  bool isAddingOtp = false;
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
                    ? showProgress
                    ? const CircularProgressIndicator()
                    :SizedBox(
                        width: size.width * 0.8,
                        child: OutlinedButton(
                          onPressed: () async {
                            if (!isAddingOtp) {
                              await startAddingPhoneNumber(context);
                            } else {
                              setState(() {
                                showProgress = true;
                              });
                              log("User has entered the otp: ${phoneNumberController.text}");
                              PhoneAuthCredential credential =
                              PhoneAuthProvider.credential(verificationId: _verificationId, smsCode: phoneNumberController.text);
                              _globalService.firebaseAuth.currentUser!.linkWithCredential(credential).then((value) async {;

                                final currentUserProvider =
                                Provider.of<CurrentUserProvider>(context, listen: false);
                                EnsoUser currentEnsoUser = currentUserProvider.currentEnsoUser;
                                currentEnsoUser.hasTriggeredConfirmationSms = true;
                                currentUserProvider
                                    .setCurrentEnsoUser(currentEnsoUser);
                                // _globalService.currentEnsoUser.hasTriggeredConfirmationSms = true;

                                final prefs =
                                await SharedPreferences.getInstance();
                                // try {
                                prefs.setBool(Constants.hasTriggeredConfirmationSms, true);
                                _globalService.showScreen(
                                    context, VerificationOverviewScreen());

                              }).onError((error, stackTrace) {
                                log(error.toString());
                                return null;
                              });
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
          log("Oh yeah, verificationCompleted");

          EnsoUser user = await _databaseRepo.getUserFromDB(currentEnsoUser.id!);
          user.phoneVerified = true;
          await _globalService.firebaseAuth.currentUser!.linkWithCredential(credential);
          currentUserProvider
              .setCurrentEnsoUser(currentEnsoUser);
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
          isAddingOtp = true;
          buttonText = Constants.checkOtp;
          phoneNumberController.text = '123456';
          _verificationId = verificationId;
          _resendToken = resendToken;

          setState(() {
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
        timeout: const Duration(seconds: 30),
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-resolution timed out...
          log("codeAutoRetrievelTimeout - phone could not get verified");
          // TODO: Error Screen
        });
  }
}
