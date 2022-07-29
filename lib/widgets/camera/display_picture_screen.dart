// A widget that displays the picture taken by the user.

import 'dart:developer';
import 'dart:io' as io;
import 'dart:io';

import 'package:ensobox/models/enso_user.dart';
import 'package:ensobox/models/photo_side.dart';
import 'package:ensobox/models/photo_type.dart';
import 'package:ensobox/widgets/camera/selfie_explanation_screen.dart';
import 'package:ensobox/widgets/camera/take_picture_screen.dart';
import 'package:ensobox/widgets/firebase_repository/storage_repo.dart';
import 'package:ensobox/widgets/id_scanner/user_id_details_screen.dart';
import 'package:ensobox/widgets/services/global_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../service_locator.dart';

GlobalService _globalVariablesService = getIt<GlobalService>();

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
    EnsoUser currentUser = Provider.of<EnsoUser>(context, listen: false);

    _showCamera() async {
      if (_globalVariablesService.cameras != null &&
          _globalVariablesService.cameras!.first != null) {
        final camera = _globalVariablesService.cameras!.first;

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TakePictureScreen(
                camera: camera,
                photoType: PhotoType.id,
                photoSide: PhotoSide.back),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
          title: photoSide == PhotoSide.front
              ? const Text('Vorderseite prüfen')
              : const Text('Rückseite prüfen')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Column(
        children: [
          Text("Alles gut lesbar?"),
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
              Navigator.pop(context);
              break;
            case 1:
              log("Pressed 111" + itemIndex.toString());
              if (photoType == PhotoType.id && photoSide == PhotoSide.front) {
                // currentUser.frontIdPhoto = io.File(imagePath) as File?;
                StorageRepo _storage = getIt<StorageRepo>();
                _storage.storeFileOnPhone(File(imagePath));
                _storage.uploadFile(
                    context,
                    "user/idphoto/${currentUser.id}/frontside",
                    File(imagePath),
                    photoType,
                    photoSide);
                _globalVariablesService.isComingFromTakePictureScreen = true;
                _showCamera();
              } else if (photoType == PhotoType.id &&
                  photoSide == PhotoSide.back) {
                _globalVariablesService.isComingFromTakePictureScreen = false;
                _globalVariablesService.showScreen(
                    context, SelfieExplanationScreen());
              }

            // showUserIdDetailsScreen(context);
          }
        },
      ),
    );
  }
}
