import 'dart:developer';

import 'package:ensobox/widgets/auth/verification_overview_screen.dart';
import 'package:ensobox/widgets/services/global_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  TextEditingController otpController = TextEditingController(text: '123456');
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
          title: Text("Bitte Passcode eingeben"),
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
                            // Create a PhoneAuthCredential with the code
                            PhoneAuthCredential credential =
                                PhoneAuthProvider.credential(
                                    verificationId:
                                        _globalService.phoneAuthVerificationId,
                                    smsCode: otpController.text);

// Sign the user in (or link) with the credential
// use .onError to handle wrong code, but needs to return Future
                            await _auth
                                .signInWithCredential(credential)
                                .then((value) {
                              _globalService.showScreen(
                                  context, VerificationOverviewScreen());
                            }).onError((error, stackTrace) {
                              log(error.toString());
                              return null;
                            });

                            // registerService.registerByEmailAndHiddenPW("grg.kro@gmail.com");
                          },
                          child: Text(Constants.checkOtp),
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
}
