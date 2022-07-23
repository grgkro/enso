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
      TextEditingController(text: "g.rgkro@gmail.com");
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
                            log("got ${emailController.text}");
                            String password = generateRandPassword();
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setString('randEmailPassword', password);
                            AuthCredential emailCredential =
                                EmailAuthProvider.credential(
                                    email: emailController.text,
                                    password: password);
                            PhoneAuthCredential phoneCredential =
                                PhoneAuthProvider.credential(
                                    verificationId:
                                        _globalService.phoneAuthVerificationId,
                                    smsCode: '123456');
                            await _auth.signInWithCredential(phoneCredential);
                            // _globalService.showScreen(
                            //     context, VerificationOverviewScreen());

                            _auth.currentUser
                                ?.linkWithCredential(emailCredential)
                                .then((value) {
                              log('linked email to existing account');
                              _globalService.isEmailVerified = true;
                              _globalService.showScreen(
                                  context, VerificationOverviewScreen());
                            });

                            // registerService.registerByEmailAndHiddenPW("grg.kro@gmail.com");
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
    log("TODO: generate real rand pw instead of HorseAsk");
    return "HorseAsk";
  }
}
