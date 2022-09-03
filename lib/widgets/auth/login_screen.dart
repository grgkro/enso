import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../service_locator.dart';
import '../services/global_service.dart';
import 'fade_animation.dart';

GlobalService _globalService = getIt<GlobalService>();

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
              // Colors.purple,
              Colors.purple.shade600,
              Colors.deepPurpleAccent,
            ])),
        child: Column(
          children: [
            Container(
                margin: const EdgeInsets.only(top: 100),
                child: const FadeAnimation(
                  2,
                  Text(
                    "Fairleihbox",
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
                  ),
                )),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50))),
                margin: const EdgeInsets.only(top: 60),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 50,
                        ),
                        Container(
                            // color: Colors.red,
                            alignment: Alignment.topLeft,
                            margin: const EdgeInsets.only(left: 22, bottom: 20),
                            child: const FadeAnimation(
                              2,
                              Text(
                                "Login",
                                style: TextStyle(
                                    fontSize: 35,
                                    color: Colors.black87,
                                    // letterSpacing: 2,
                                    fontFamily: "Lobster"),
                              ),
                            )),
                        FadeAnimation(
                          2,
                          Container(
                              width: double.infinity,
                              height: 70,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.purpleAccent, width: 1),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.purpleAccent,
                                        blurRadius: 10,
                                        offset: Offset(1, 1)),
                                  ],
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20))),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Icon(Icons.email_outlined),
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 10),
                                      child: TextFormField(
                                        autofocus: true,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        controller: _emailController,
                                        textInputAction: TextInputAction.next,
                                        validator: (value) =>
                                            _globalService.validateEmail(value),
                                        maxLines: 1,
                                        decoration: const InputDecoration(
                                          label: Text(" E-mail ..."),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                        ),
                        FadeAnimation(
                          2,
                          Container(
                              width: double.infinity,
                              height: 70,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.purpleAccent, width: 1),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.purpleAccent,
                                        blurRadius: 10,
                                        offset: Offset(1, 1)),
                                  ],
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20))),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Icon(Icons.password_outlined),
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 10),
                                      child: TextFormField(
                                        keyboardType:
                                        TextInputType.visiblePassword,
                                        obscureText: true,
                                        controller: _passwordController,
                                        textInputAction: TextInputAction.done,
                                        validator: (value) =>
                                            _globalService.validatePassword(value),
                                        maxLines: 1,
                                        decoration: const InputDecoration(
                                          label: Text(" Password ..."),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        FadeAnimation(
                          2,
                          ElevatedButton(
                            onPressed: () {
                              // Validate returns true if the form is valid, or false otherwise.
                              if (_formKey.currentState!.validate()) {
                                // If the form is valid, display a snackbar. In the real world,
                                // you'd often call a server or save the information in a database.
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Processing Data')),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                onPrimary: Colors.purpleAccent,
                                shadowColor: Colors.purpleAccent,
                                elevation: 18,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20))),
                            child: Ink(
                              decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [
                                    Colors.purpleAccent,
                                    Colors.deepPurpleAccent
                                  ]),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Container(
                                width: 200,
                                height: 50,
                                alignment: Alignment.center,
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 30,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        FadeAnimation(
                          2,
                          Container(
                              width: double.infinity,
                              height: 70,
                              alignment: Alignment.center,
                              margin: const EdgeInsets.only(top: 10),
                              child: const Text(
                                " Subscribe in social Media App ",
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 15),
                              )),
                        ),
                        FadeAnimation(
                          2,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/social/Facebook.png",
                                width: 80,
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Image.asset(
                                "assets/social/Instagram.png",
                                width: 80,
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Image.asset(
                                "assets/social/Tiktok.png",
                                width: 80,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _login() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // final AuthCredential emailCredential = EmailAuthProvider.credential(
    //     email: emailController.text, password: password);
  }
}
