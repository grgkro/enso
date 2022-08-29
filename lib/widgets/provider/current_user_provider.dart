import 'dart:developer';

import 'package:ensobox/models/enso_user.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class CurrentUserProvider with ChangeNotifier {
  EnsoUser currentEnsoUser = EnsoUser(EnsoUserBuilder());

  Future<void> setCurrentEnsoUser(EnsoUser ensoUser) async {
    currentEnsoUser = ensoUser;
    log("currentEnsoUser has been changed in the CurrentUserProvider");
    Timer(Duration(seconds: 1), () {
      print('done waiting');
      notifyListeners();
    });

  }

  EnsoUser get currentUser {
    // if we directly returned currentEnsoUser, we'd pass the pointer. Then anywhere in the code we could edit the list.
    return currentEnsoUser;
  }
}