import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ensobox/widgets/auth/email_auth_form.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/constants.dart' as Constants;
import '../../firebase_options.dart';
import '../../models/enso_user.dart';
import '../../models/rental.dart';
import '../service_locator.dart';
import '../services/global_service.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
GlobalService _globalService = getIt<GlobalService>();

class RentalRepo {

  Future<Rental> getRental(String userId) {
    return Future<Rental>.value(Rental(RentalBuilder()));
  }


}
