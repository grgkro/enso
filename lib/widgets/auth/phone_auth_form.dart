import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/constants.dart' as Constants;
import '../firebase_repository/auth_repo.dart';
import '../service_locator.dart';

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
                    ? SizedBox(
                        width: size.width * 0.8,
                        child: OutlinedButton(
                          onPressed: () async {
                            log("got ${phoneNumberController.text}");
                            await registerService.verifyPhoneNumber(
                                phoneNumberController.text, context);

                            // registerService.registerByEmailAndHiddenPW("grg.kro@gmail.com");
                          },
                          child: Text(Constants.textSignIn),
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
