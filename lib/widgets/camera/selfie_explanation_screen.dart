import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SelfieExplanationScreen extends StatefulWidget {
  const SelfieExplanationScreen({Key? key}) : super(key: key);

  @override
  State<SelfieExplanationScreen> createState() =>
      _SelfieExplanationScreenState();
}

class _SelfieExplanationScreenState extends State<SelfieExplanationScreen> {
  @override
  Widget build(BuildContext context) {
    Random rng = new Random();
    int rand = rng.nextInt(90000) + 10000;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Selfie hinzufügen'),
        backgroundColor: Colors.green[700],
      ),
      resizeToAvoidBottomInset: false,
      body: Container(
        child: Text(
            'Um sicher zu gehen, dass es sich auch wirklich um deinen Personalausweis handelt, benötigen wir noch ein Selfie von dir. Bitte schreibe auf ein Stück Papier folgende Zahl auf und mache ein Selfie bei dem sowohl das Papier mit der Zahl, als auch dein Gesicht gut zu erkennen ist.'),
      ),
    );
  }
}
