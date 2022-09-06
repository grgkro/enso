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
import '../globals/enso_divider.dart';
import '../provider/current_user_provider.dart';
import '../service_locator.dart';
import '../services/global_service.dart';
import 'login_screen.dart';

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
      TextEditingController(text: _globalService.emailInput);
  TextEditingController otpCode = TextEditingController();

  OutlineInputBorder border = const OutlineInputBorder(
      borderSide: BorderSide(color: Constants.kBorderColor, width: 3.0));

  bool isLoading = false;
  bool showProgress = false;

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
            child: SingleChildScrollView(
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
                                setState(() {
                                  isLoading = true;
                                });

                                log("got email input: ${emailController.text}");
                                _globalService.emailInput =
                                    emailController.text;

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
                                    log('User was null after createUserWithEmailAndPassword');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Anlegen eines neuen Accounts wurde unerwartet abgelehnt, genauer Grund unbekannt.'),
                                          duration: Duration(seconds: 20),
                                          action: SnackBarAction(
                                            label: 'Admins informieren',
                                            onPressed: () {
                                              // TODO: add Admins informieren?
                                              ScaffoldMessenger.of(context)
                                                  .hideCurrentSnackBar();
                                            },
                                          )),
                                    );
                                  }
                                } on FirebaseAuthException catch (e) {
                                  if (e.code ==
                                      'account-exists-with-different-credential') {
                                    // The account already exists with a different credential
                                    String email = emailController.text;
                                    AuthCredential? pendingCredential =
                                        e.credential;

                                    if (pendingCredential == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Anlegen eines neuen Accounts wurde unerwartet abgelehnt, genauer Grund unbekannt.'),
                                            duration: Duration(seconds: 20),
                                            action: SnackBarAction(
                                              label: 'Admins informieren',
                                              onPressed: () {
                                                ScaffoldMessenger.of(context)
                                                    .hideCurrentSnackBar();
                                              },
                                            )),
                                      );
                                    }
                                    // Fetch a list of what sign-in methods exist for the conflicting user
                                    List<String> userSignInMethods =
                                        await _globalService.firebaseAuth
                                            .fetchSignInMethodsForEmail(email);

                                    // If the user has several sign-in methods,
                                    // the first method in the list will be the "recommended" method to use.
                                    if (userSignInMethods.first == 'password') {
                                      // TODO: Prompt the user to enter their password
                                      String password = '...';

                                      // Sign the user in to their account with the password
                                      UserCredential userCredential =
                                          await _globalService.firebaseAuth
                                              .signInWithEmailAndPassword(
                                        email: email,
                                        password: password,
                                      );

                                      // Link the pending credential with the existing account
                                      await userCredential.user!
                                          .linkWithCredential(
                                              pendingCredential!);

                                      newEnsoUser.id = userCredential.user!.uid;
                                      newEnsoUser.email =
                                          userCredential.user!.email;

                                      // Success!
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(Constants
                                              .successfullyCreatedAccount),
                                          duration: Duration(seconds: 20),
                                        ),
                                      );
                                    }
                                    // Handle other OAuth providers...
                                  } else {
                                    _globalService.handleFirebaseAuthException(
                                        context, e);
                                  }
                                } catch (e) {
                                  print(e);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(e.toString()),
                                      duration: Duration(seconds: 20),
                                    ),
                                  );
                                }

                                if (newEnsoUser.email != null) {
                                  try {
                                    final bool hasSendEmail =
                                        await _functionsRepo
                                            .sendVerificationEmail(
                                      context,
                                      newEnsoUser.id,
                                      emailController.text,
                                    );
                                    if (hasSendEmail) {
                                      newEnsoUser
                                          .hasTriggeredConfirmationEmail = true;
                                    } else {
                                      // the creation of the user in firestore by cloud function triggered
                                      // at creation of the user in authentication needs some time, so maybe it's not finished yet
                                      await Future.delayed(
                                          const Duration(milliseconds: 1300));
                                      log('hasSendEmail = false, probably clouf function triggered by user creation has not finished, going to wait 1.3 s and try again.');

                                      final bool hasSendEmail =
                                          await _functionsRepo
                                              .sendVerificationEmail(
                                        context,
                                        newEnsoUser.id,
                                        emailController.text,
                                      );

                                      if (hasSendEmail) {
                                        newEnsoUser
                                                .hasTriggeredConfirmationEmail =
                                            true;
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Anlegen eines neuen Accounts wurde unerwartet abgelehnt, genauer Grund unbekannt.'),
                                            duration: Duration(seconds: 20),
                                            action: SnackBarAction(
                                              label: 'Admins informieren',
                                              onPressed: () {
                                                // TODO: add Admins informieren?
                                                ScaffoldMessenger.of(context)
                                                    .hideCurrentSnackBar();
                                              },
                                            ),
                                          ),
                                        );
                                      }
                                    }

                                    final CurrentUserProvider
                                        currentUserProvider =
                                        Provider.of<CurrentUserProvider>(
                                            context,
                                            listen: false);
                                    currentUserProvider
                                        .setCurrentEnsoUser(newEnsoUser);

                                    _databaseRepo.updateUser(newEnsoUser);

                                    prefs.setString(Constants.emailKey,
                                        emailController.text);
                                    prefs.setString(
                                        Constants.emailPasswordKey, password);

                                    Navigator.popAndPushNamed(
                                        context, '/verification');
                                  } catch (e) {
                                    // TODO: what to do if this fails? ErrorScreen
                                    log('Error while signing in with email: ${e.toString()}');
                                  }
                                }

                                setState(() {
                                  isLoading = false;
                                });

                                // _globalService.showScreen(
                                //     context, VerificationOverviewScreen());
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
                  loginFooter(),
                ],
              ),
            ),
          ),
        ));
  }

  Widget loginFooter() {
    return Column(
      children: [
        const EnsoDivider(),
        Text("Du hast bereits einen Account?"),
        ElevatedButton(
          onPressed: () {
            log("User already has an account, going to LoginScreen");
            _globalService.showScreen(context, LoginScreen());
          },
          child: const Text('Einloggen'),
        ),
      ],
    );
  }

  String generateRandPassword() {
    // TODO: generate real rand pw instead of HorseAsk
    log("TODO: generate real rand pw instead of HorseAsk");
    return "HorseAsk";
  }
}
