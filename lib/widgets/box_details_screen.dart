import 'package:flutter/material.dart';

class BoxDetailsScreen extends StatefulWidget {
  const BoxDetailsScreen({Key? key}) : super(key: key);

  @override
  State<BoxDetailsScreen> createState() => _BoxDetailsScreenState();
}

class _BoxDetailsScreenState extends State<BoxDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('The box'),
        ),
        body: Center(
          child: Text('Hello to the box details!'),
        ));
  }
}
