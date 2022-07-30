import 'package:ensobox/models/enso_user.dart';

class DatabaseRepo {
  EnsoUser getUser(String uid) {
    // replace with actual user from Firestore
    EnsoUser ensoUser = EnsoUser(EnsoUserBuilder());
    ensoUser.id = "testUid";
    ensoUser.email = "grg.kro@gmail.com";
    ensoUser.frontIdPhotoUrl = "testUrlFront";
    ensoUser.backIdPhotoUrl = "testUrlBack";
    ensoUser.backIdPhotoUrl = "testUrlBack";
    ensoUser.emailVerified = false;
    ensoUser.phoneVerified = false;
    ensoUser.idUploaded = false;
    return ensoUser;
  }
  // dynamic createUser() {
  //   return createUser = functions.auth.user().onCreate((user) => {
  //   const { uid, displayName, email } = user;
  //
  //       return admin.firestore()
  //       .collection('users')
  //       .doc(uid)
  //       .set({ uid, displayName, email })
  // });
  // }

}
