import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EnsoCircularProgressIndicator extends StatelessWidget {
  const EnsoCircularProgressIndicator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 100,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
