import 'dart:developer';

import 'package:ensobox/widgets/auth/login_screen.dart';
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

class EmailSignInForm extends StatefulWidget {
  EmailSignInForm({Key? key}) : super(key: key);

  @override
  _EmailSignInFormState createState() => _EmailSignInFormState();
}

class _EmailSignInFormState extends State<EmailSignInForm> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController =
      TextEditingController(text: _globalService.email);
  TextEditingController otpController =
      TextEditingController(text: _globalService.otp);

  OutlineInputBorder border = OutlineInputBorder(
      borderSide: BorderSide(color: Constants.kBorderColor, width: 3.0));

  bool isLoading = false;
  bool showProgress = false;
  bool showOtpForm = false;
  String buttonText = Constants.textSignInWithEmail;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
  }

  @override
  void initState() {
    super.initState();
    tryGettingEmailFromSharedPrefsNoAwait();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Passwort zurücksetzen"),
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
                child: const Text(
                    "Wir senden dir eine Email zum Passwort zurücksetzen"),
              ),
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
                  ? showProgress
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: size.width * 0.8,
                          child: OutlinedButton(
                            child: Text(buttonText),
                            onPressed: () async {
                              setState(() {
                                showProgress = true;
                              });
                              log("Received email: ${emailController.text}");
                              await FirebaseAuth.instance
                                  .sendPasswordResetEmail(
                                      email: emailController.text.trim())
                                  .then((value) {
                                log("Sent pw reset email");
                                setState(() {
                                  showProgress = false;
                                });
                                _globalService.showOpenMailAppSnack(context);
                                _globalService.showScreen(
                                    context, LoginScreen());
                              }).onError(
                                (FirebaseAuthException error, stackTrace) {
                                  log(stackTrace.toString());
                                  setState(() {
                                    showProgress = false;
                                  });
                                  _globalService.handleFirebaseAuthException(
                                      context, error);
                                },
                              );
                            },
                          ),
                        )
                  : CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> tryGettingEmailFromSharedPrefsNoAwait() async {
    log("Getting email from sharedPrefs");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? emailFromPrefs = prefs.getString(Constants.emailKey);
    if (emailFromPrefs != null) {
      log("Going to call setState for controller.text = $emailFromPrefs");
      setState(() {
        emailController.text = emailFromPrefs;
      });
    } else {
      log("emailFromPrefs was null, let the user type it in.");
    }
  }
}
