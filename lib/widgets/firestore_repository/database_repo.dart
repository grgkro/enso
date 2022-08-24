import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ensobox/models/enso_user.dart';

class DatabaseRepo {
  final CollectionReference _usersCollectionReference =
  FirebaseFirestore.instance.collection("users");

  late EnsoUser _currentUser;

  EnsoUser getUser(String uid) {
    // replace with actual user from Firestore
    final EnsoUser ensoUser = EnsoUser(EnsoUserBuilder());
    ensoUser.id = uid;
    ensoUser.email = "grg.kro@gmail.com";
    ensoUser.frontIdPhotoUrl = "testUrlFront";
    ensoUser.backIdPhotoUrl = "testUrlBack";
    ensoUser.backIdPhotoUrl = "testUrlBack";
    ensoUser.emailVerified = false;
    ensoUser.phoneVerified = false;
    ensoUser.idUploaded = false;
    return ensoUser;
  }

  Future getUserFromDB(String uid) async {
    try {
      DocumentSnapshot<Object?> userData = await _usersCollectionReference.doc(uid).get();

      return EnsoUser.fromData(userData.data() as Map<String, dynamic>);
    } catch (e) {
      return e.toString();
    }
  }

  Future createUser(EnsoUser user) async {
    try {
      await _usersCollectionReference.doc(user.id).set(user.toJson());
    } catch (e) {
      return e.toString();
    }
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
