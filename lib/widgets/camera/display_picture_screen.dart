// A widget that displays the picture taken by the user.

import 'dart:developer';
import 'dart:io' as io;
import 'dart:io';

import 'package:camera_platform_interface/src/types/camera_description.dart';
import 'package:ensobox/models/enso_user.dart';
import 'package:ensobox/models/photo_side.dart';
import 'package:ensobox/models/photo_type.dart';
import 'package:ensobox/widgets/camera/display_selfie_id_pictures_screen.dart';
import 'package:ensobox/widgets/camera/selfie_explanation_screen.dart';
import 'package:ensobox/widgets/camera/take_picture_screen.dart';
import 'package:ensobox/widgets/firebase_repository/storage_repo.dart';
import 'package:ensobox/widgets/id_scanner/user_id_details_screen.dart';
import 'package:ensobox/widgets/services/global_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../service_locator.dart';

GlobalService _globalService = getIt<GlobalService>();

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final PhotoType photoType;
  final PhotoSide photoSide;

  const DisplayPictureScreen(
      {super.key,
      required this.imagePath,
      required this.photoType,
      required this.photoSide});

  void showUserIdDetailsScreen(BuildContext ctx) {
    log("Pressed continue");
    Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
      return UserIdDetailsScreen();
    }));
  }

  @override
  Widget build(BuildContext context) {
    final EnsoUser currentEnsoUser = context.read<EnsoUser>();

    CameraDescription? camera;
    if (_globalService.cameras != null &&
        _globalService.cameras!.isNotEmpty) {
      if (photoType == PhotoType.selfie) {
        camera = _globalService.cameras![1];
      } else {
        camera = _globalService.cameras![0];
      }
    }

    Future<void> _showCamera() async {
      if (camera == null) {
        // TODO: no camera found
        log('no camera found');
        return;
      }
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TakePictureScreen(
              camera: camera!,
              photoType: PhotoType.id,
              photoSide: PhotoSide.back),
        ),
      );
    }

    String appBarTitle = "";
    String upperText = "Alles gut lesbar?";
    if (photoType == PhotoType.id && photoSide == PhotoSide.front) {
      appBarTitle = 'Vorderseite prüfen';
    } else if (photoType == PhotoType.id && photoSide == PhotoSide.back) {
      appBarTitle = 'Rückseite prüfen';
    } else if (photoType == PhotoType.selfie) {
      appBarTitle = 'Selfie mit ${currentEnsoUser.selfieRandomNumber.toString()}';
      upperText =
          'Bitte stell sicher, dass dein Gesicht und die Zahl ${currentEnsoUser.selfieRandomNumber.toString()} gut zu erkennen sind.';
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Column(
        children: [
          Text(upperText),
          Expanded(
            child: Container(
              width: MediaQuery.of(context)
                  .size
                  .width, // or use fixed size like 200
              // height: MediaQuery.of(context).size.height / 2 - 100,
              child: Image.file(io.File(imagePath)),
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.blue,
              ),
              label: "Zurück"),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.done_all,
                color: Colors.blue,
              ),
              label: "Ok"),
        ],
        onTap: (int itemIndex) {
          log("Pressed" + itemIndex.toString());
          switch (itemIndex) {
            case 0:
              _showCamera();
              break;
            case 1:
              log("Pressed 111" + itemIndex.toString());
              if (photoType == PhotoType.id && photoSide == PhotoSide.front) {
                // currentUser.frontIdPhoto = io.File(imagePath) as File?;
                StorageRepo _storage = getIt<StorageRepo>();
                _storage.storeFileOnPhone(File(imagePath));
                _storage.uploadFile(
                    context,
                    "user/idphoto/${currentEnsoUser.id}/frontside",
                    File(imagePath),
                    photoType,
                    photoSide);
                _globalService.isComingFromTakePictureScreen = true;
                _showCamera();
              } else if (photoType == PhotoType.id &&
                  photoSide == PhotoSide.back) {
                _globalService.isComingFromTakePictureScreen = false;
                _globalService.showScreen(
                    context, SelfieExplanationScreen());
              } else if (photoType == PhotoType.selfie) {
                log("Got all photos, going to the terms and conditions screen");
                _globalService.showScreen(
                    context, DisplaySelfieIdPicturesScreen());
              }

            // showUserIdDetailsScreen(context);
          }
        },
      ),
    );
  }
}
