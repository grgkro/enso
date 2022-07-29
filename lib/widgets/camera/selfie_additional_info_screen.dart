import 'dart:developer';

import 'package:ensobox/widgets/auth/verification_overview_screen.dart';
import 'package:ensobox/widgets/camera/take_picture_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/photo_side.dart';
import '../../models/photo_type.dart';
import '../service_locator.dart';
import '../services/global_service.dart';

GlobalService _globalVariablesService = getIt<GlobalService>();

class SelfieAdditionalInfoScreen extends StatelessWidget {
  const SelfieAdditionalInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _showCamera() async {
      if (_globalVariablesService.cameras != null &&
          _globalVariablesService.cameras!.first != null) {
        final camera = _globalVariablesService.cameras![1];

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TakePictureScreen(
                camera: camera,
                photoType: PhotoType.selfie,
                photoSide: PhotoSide.back),
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Selfie hinzufügen'),
        backgroundColor: Colors.green[700],
      ),
      resizeToAvoidBottomInset: false,
      body: Container(child: Text('Just trust me, bro!')),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.blue,
              ),
              label: "Abbrechen"),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.done_all,
                color: Colors.blue,
              ),
              label: "Kamera öffnen"),
        ],
        onTap: (int itemIndex) {
          log("Pressed" + itemIndex.toString());
          switch (itemIndex) {
            case 0:
              _globalVariablesService.showScreen(
                  context, VerificationOverviewScreen());
              break;
            case 1:
              _showCamera();

            // showUserIdDetailsScreen(context);
          }
        },
      ),
    );
  }
}
