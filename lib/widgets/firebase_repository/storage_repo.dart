import 'dart:developer';
import 'dart:io';

import 'package:ensobox/widgets/service_locator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../models/enso_user.dart';
import '../../models/photo_side.dart';
import '../../models/photo_type.dart';
import 'auth_repo.dart';

class StorageRepo {
  // Create a storage reference from our app
  FirebaseStorage storage = FirebaseStorage.instanceFor(
    bucket: "gs://enso-fairleih.appspot.com",
  );

  AuthRepo _authRepo = getIt<AuthRepo>();

  uploadFile(BuildContext ctx, String refPath, File file, PhotoType photoType,
      PhotoSide photoSide) async {
    EnsoUser currentUser = Provider.of<EnsoUser>(ctx, listen: false);
    // Create a reference to "path"
    var storageRef =
        // storage.ref().child("user/idphoto/${currentUser.id}/frontside");
        storage.ref().child(refPath);
    try {
      await storageRef.putFile(file);
      var photoUrl = await storageRef.getDownloadURL();
      if (photoType == PhotoType.id && photoSide == PhotoSide.front) {
        currentUser.frontIdPhoto = photoUrl;
      } else if (photoType == PhotoType.id && photoSide == PhotoSide.back) {
        currentUser.backIdPhoto = photoUrl;
      } else {
        log("Can't save photoUrl to currentUser, passport photos not implemented yet.");
      }
    } on FirebaseException catch (e) {
      log("Big trouble while uploading photo to firstore.");
    }
  }
}
