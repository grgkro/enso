import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/enso_user.dart';

class UserAddEmail extends StatefulWidget {
  const UserAddEmail({Key? key}) : super(key: key);

  @override
  State<UserAddEmail> createState() => _UserAddEmailState();
}

class _UserAddEmailState extends State<UserAddEmail> {
  final _formKey = GlobalKey<FormState>();

  final FocusNode _emailFocusNode = FocusNode();

  final TextEditingController _emailController = TextEditingController();

//   var acs = ActionCodeSettings(
//       // URL you want to redirect back to. The domain (www.example.com) for this
//       // URL must be whitelisted in the Firebase Console.
//       url: 'enso-fairleih.firebaseapp.com/finishSignUp?cartId=1234',
//       // This must be true
//       handleCodeInApp: true,
//       iOSBundleId: 'com.example.ios',
//       androidPackageName: 'com.example.android',
//       // installIfNotAvailable
//       androidInstallApp: true,
//       // minimumVersion
//       androidMinimumVersion: '12');
//   var emailAuth = 'someemail@domain.com';
//   FirebaseAuth.instance.sendSignInLinkToEmail(
//   email: emailAuth, actionCodeSettings: acs)
//       .catchError((onError) => print('Error sending email verification $onError'))
//       .then((value) => print('Successfully sent email verification'));
// });

  _submitForm() {
    if (_formKey.currentState?.validate() != null) {
      final user = {
        'email': _emailController.text,
      };
      print(user.toString());

      // If the form passes validation, display a Snackbar.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('snack'),
        duration: const Duration(seconds: 1),
        action: SnackBarAction(
          label: 'ACTION',
          onPressed: () {},
        ),
      ));
      //_formKey.currentState.save();
      //_formKey.currentState.reset();
      //_nextFocus(_nameFocusNode);
    }
  }

  String? _validateEmail(String? value) {
    String pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = RegExp(pattern);
    if (value == null || value.isEmpty || !regex.hasMatch(value))
      return 'Enter a valid email address';
    else
      return null;
  }

  @override
  Widget build(BuildContext context) {
    EnsoUser currentUser = Provider.of<EnsoUser>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello There'),
        // title: Text(Pay.gPay != null &&
        //         Pay.gPay.paymentMethodData != null &&
        //         Pay.gPay.paymentMethodData.info != null &&
        //         Pay.gPay.paymentMethodData.info.billingAddress != null &&
        //         Pay.gPay.paymentMethodData.info.billingAddress.name != null
        //     ? "Hallo ${Pay.gPay.paymentMethodData.info.billingAddress.name.split(" ")[0]}"
        //     : "Hallo ${currentUser.givenNames != null ? currentUser.givenNames!.split(" ")[0] : ''}"),
      ),
      body: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      autofocus: true,
                      focusNode: _emailFocusNode,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      validator: (value) => _validateEmail(value),
                      onFieldSubmitted: (String value) {
                        _submitForm();
                      },
                      decoration: InputDecoration(
                        hintText: 'max.muster@man.de',
                        labelText: 'Als letztes noch deine Email:',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
