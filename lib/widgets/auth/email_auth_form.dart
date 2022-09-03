import 'dart:developer';

import 'package:ensobox/models/enso_user.dart';
import 'package:ensobox/widgets/auth/verification_overview_screen.dart';
import 'package:ensobox/widgets/firestore_repository/database_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../constants/constants.dart' as Constants;
import '../firebase_repository/auth_repo.dart';
import '../firestore_repository/functions_repo.dart';
import '../provider/current_user_provider.dart';
import '../service_locator.dart';
import '../services/global_service.dart';

GlobalService _globalService = getIt<GlobalService>();
FunctionsRepo _functionsRepo = getIt<FunctionsRepo>();
DatabaseRepo _databaseRepo = getIt<DatabaseRepo>();

class EmailAuthForm extends StatefulWidget {
  EmailAuthForm({Key? key}) : super(key: key);

  @override
  _EmailAuthFormState createState() => _EmailAuthFormState();
}

class _EmailAuthFormState extends State<EmailAuthForm> {
  final FirebaseAuth _firebaseAuth = _globalService.firebaseAuth;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController =
      TextEditingController(text: "grgk.ro@gmail.com");
  TextEditingController otpCode = TextEditingController();

  OutlineInputBorder border = const OutlineInputBorder(
      borderSide: BorderSide(color: Constants.kBorderColor, width: 3.0));

  bool isLoading = false;

  String? verificationId;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthRepo _authRepo = getIt<AuthRepo>();

    final Size size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          title: const Text("Bitte Email eingeben"),
          systemOverlayStyle:
              const SystemUiOverlayStyle(statusBarColor: Colors.blue),
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
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        contentPadding: const EdgeInsets.symmetric(
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
                            child: const Text(Constants.textSignInEmail),
                            onPressed: () async {
                              log("got email input: ${emailController.text}");

                              final SharedPreferences prefs =
                                  await SharedPreferences.getInstance();

                              final String password = generateRandPassword();

                              EnsoUser newEnsoUser =
                                  EnsoUser(EnsoUserBuilder());
                              try {
                                final credential = await _globalService
                                    .firebaseAuth
                                    .createUserWithEmailAndPassword(
                                  email: emailController.text,
                                  password: password,
                                );
                                if (credential.user != null) {
                                  log("CREDENTIAL: ${credential.user!.uid}");
                                  newEnsoUser.id = credential.user!.uid;
                                  newEnsoUser.email = credential.user!.email;
                                } else {
                                  // TODO: what to do now?
                                  log('Should not happen');
                                }
                              } on FirebaseAuthException catch (e) {
                                if (e.code == 'weak-password') {
                                  log('The password provided is too weak.');
                                  //TODO: macht keinen Sinn, da User PW nicht wählen darf.
                                  return;
                                } else if (e.code == 'email-already-in-use') {
                                  log('The account already exists for that email.');
                                  // TODO: Show Snack
                                  return;
                                } else if (e.code == 'invalid-email') {
                                  log('invalid-email');
                                  // TODO: Show Snack
                                  return;
                                } else {
                                  log('Unexpected FirebaseAuthException: ${e.code}');
                                  // TODO: Show Snack
                                  return;
                                }
                              } catch (e) {
                                print(e);
                                return;
                              }

                              try {
                                final bool hasSendEmail =
                                    await _functionsRepo.sendVerificationEmail(
                                  context,
                                  newEnsoUser.id,
                                  emailController.text,
                                );
                                if (hasSendEmail) {
                                  newEnsoUser.hasTriggeredConfirmationEmail =
                                      true;
                                }

                                final currentUserProvider =
                                    Provider.of<CurrentUserProvider>(context,
                                        listen: false);
                                currentUserProvider
                                    .setCurrentEnsoUser(newEnsoUser);

                                _databaseRepo.updateUser(newEnsoUser);

                                prefs.setString(
                                    Constants.emailKey, emailController.text);
                                prefs.setString(
                                    Constants.emailPasswordKey, password);
                              } catch (e) {
                                // TODO: what to do if this fails? ErrorScreen
                                log('Error while signing in with email: ${e.toString()}');
                              }

                              _globalService.showScreen(
                                  context, VerificationOverviewScreen());
                            }

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
