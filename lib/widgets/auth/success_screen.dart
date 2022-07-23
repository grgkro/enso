import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  static const routeName = '/success';

  const SuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("Successfull registration"),
    );
  }
}
