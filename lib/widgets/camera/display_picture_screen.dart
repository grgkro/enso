// A widget that displays the picture taken by the user.

import 'dart:developer';
import 'dart:io' as io;
import 'dart:io';

import 'package:ensobox/models/enso_user.dart';
import 'package:ensobox/models/photo_side.dart';
import 'package:ensobox/models/photo_type.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(io.File(imagePath)),
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
                _storage.uploadFile(
                    context,
                    "user/idphoto/${currentUser.id}/frontside",
                    File(imagePath),
                    photoType,
                    photoSide);
              }

              _globalVariablesService.isComingFromTakePictureScreen = true;
              showUserIdDetailsScreen(context);
          }
        },
      ),
    );
  }
}
