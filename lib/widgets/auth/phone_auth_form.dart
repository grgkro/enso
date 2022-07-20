import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/constants.dart' as Constants;

class PhoneAuthForm extends StatefulWidget {
  PhoneAuthForm({Key? key}) : super(key: key);

  @override
  _PhoneAuthFormState createState() => _PhoneAuthFormState();
}

class _PhoneAuthFormState extends State<PhoneAuthForm> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController otpCode = TextEditingController();

  OutlineInputBorder border = OutlineInputBorder(
      borderSide: BorderSide(color: Constants.kBorderColor, width: 3.0));

  bool isLoading = false;

  String? verificationId;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text("Verify OTP"),
          backwardsCompatibility: false,
          systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.blue),
        ),
        backgroundColor: Constants.kPrimaryColor,
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
                      controller: phoneNumber,
                      decoration: InputDecoration(
                        labelText: "Enter Phone",
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 10.0),
                        border: border,
                      )),
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                SizedBox(
                  width: size.width * 0.8,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: otpCode,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Enter Otp",
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 10.0),
                      border: border,
                      suffixIcon: Padding(
                        child: Icon(
                          Icons.add,
                          size: 15,
                        ),
                        padding: EdgeInsets.only(top: 15, left: 15),
                      ),
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.only(bottom: size.height * 0.05)),
                !isLoading
                    ? SizedBox(
                        width: size.width * 0.8,
                        child: OutlinedButton(
                          onPressed: () async {
                            // FirebaseService service = new FirebaseService();
                            // if (_formKey.currentState!.validate()) {
                            //   setState(() {
                            //     isLoading = true;
                            //   });
                            //   await phoneSignIn(phoneNumber: phoneNumber.text);
                            // }
                          },
                          child: Text(Constants.textSignIn),
                          style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Constants.kPrimaryColor),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Constants.kBlackColor),
                              side: MaterialStateProperty.all<BorderSide>(
                                  BorderSide.none)),
                        ),
                      )
                    : CircularProgressIndicator(),
              ],
            ),
          ),
        ));
  }
}
