import 'dart:developer' as developer;
import 'dart:math';

import 'package:camera_platform_interface/src/types/camera_description.dart';
import 'package:ensobox/widgets/camera/selfie_additional_info_screen.dart';
import 'package:ensobox/widgets/camera/take_picture_screen.dart';
import 'package:ensobox/widgets/globals/enso_divider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/enso_user.dart';
import '../../models/photo_side.dart';
import '../../models/photo_type.dart';
import '../service_locator.dart';
import '../services/global_service.dart';

GlobalService _globalVariablesService = getIt<GlobalService>();

class SelfieExplanationScreen extends StatefulWidget {
  const SelfieExplanationScreen({Key? key}) : super(key: key);

  @override
  State<SelfieExplanationScreen> createState() =>
      _SelfieExplanationScreenState();
}

class _SelfieExplanationScreenState extends State<SelfieExplanationScreen> {
  @override
  Widget build(BuildContext context) {
    EnsoUser currentUser = Provider.of<EnsoUser>(context, listen: false);
    if (currentUser != null) {
      if (currentUser.selfieRandomNumber == 0) {
        Random rng = new Random();
        currentUser.selfieRandomNumber = rng.nextInt(900) + 100;
        developer.log(
            'The current user had no selfie confirmation number yet, so we gave him one ${currentUser.selfieRandomNumber.toString()}');
      }
    }

    _showCamera() async {
      if (_globalVariablesService.cameras != null &&
          _globalVariablesService.cameras!.isNotEmpty) {
        final CameraDescription camera = _globalVariablesService.cameras![1];
        developer.log('Waiting for Camera Screen');
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => TakePictureScreen(
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
      body: Container(
        child: Column(
          children: [
            const Text(
                'Um sicher zu gehen, dass es sich auch wirklich um deinen Personalausweis handelt, benötigen wir noch ein Selfie von dir. Bitte schreibe auf ein Stück Papier folgende Zahl auf und mache ein Selfie bei dem sowohl das Papier mit der Zahl, als auch dein Gesicht gut zu erkennen ist.'),
            const EnsoDivider(),
            Text(
              currentUser.selfieRandomNumber.toString(),
            ),
          ],
        ),
      ),
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
          developer.log("Pressed" + itemIndex.toString());
          switch (itemIndex) {
            case 0:
              _globalVariablesService.showScreen(
                  context, SelfieAdditionalInfoScreen());
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
