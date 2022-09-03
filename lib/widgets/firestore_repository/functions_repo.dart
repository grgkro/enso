
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/enso_user.dart';
import '../service_locator.dart';
import '../services/global_service.dart';
import '../../constants/constants.dart' as Constants;
import 'database_repo.dart';

GlobalService _globalService = getIt<GlobalService>();
DatabaseRepo _databaseRepo = getIt<DatabaseRepo>();
final HttpClient httpClient = new HttpClient();
SharedPreferences? prefs = null;

class FunctionsRepo {
  Future<bool> sendVerificationEmail(String? uid, String email) async {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }

    String? userId;
    if (uid != null) {
      userId = uid;
    } else if (_globalService.currentAuthUser?.uid != null) {
      userId = _globalService.currentAuthUser?.uid;
    } else {
      log("Can't send the confirmation email without a uid");
      return Future.value(false);
    }

    final Map<String, String> queryParameters = {
      'userId': userId!,
      'email': email
    };
    final Uri url = Uri.https('us-central1-enso-fairleih.cloudfunctions.net', '/email', queryParameters);
    log("URL for email confirmation: ${url.toString()}");

    String result;
    try {

      final HttpClientRequest request = await httpClient.getUrl(url);
      final HttpClientResponse response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        final String json = await response.transform(utf8.decoder).join();
        result = 'result from email function: $json';
        _globalService.currentEnsoUser.hasTriggeredConfirmationEmail = true;
        prefs!.setBool(Constants.hasTriggeredConfirmationEmail, true);
        return Future.value(true);
      } else {
        result =
            'Error sending confirmation email:\nHttp status: ${response.statusCode}}';
        log('result from sending verification email: $result');
        return Future.value(false);
      }
    } catch (exception) {
      result = 'Failed sending confirmation email.';
      log(exception.toString());
      log('result from sending verification email: $result');
      return Future.value(false);
    }

  }

  Future<bool> sendAdminApproveIdEmail(String? uid) async {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }

    String? userId;
    if (uid != null) {
      userId = uid;
    } else if (_globalService.currentAuthUser?.uid != null) {
      userId = _globalService.currentAuthUser?.uid;
    } else {
      log("Can't send the confirmation email without a uid");
      return Future.value(false);
    }

    final Map<String, String> queryParameters = {
      'userId': userId!,
    };
    final Uri url = Uri.https('us-central1-enso-fairleih.cloudfunctions.net', '/sendApproveMeEmail', queryParameters);
    log("URL for approve id email: ${url.toString()}");

    String result;
    try {

      final HttpClientRequest request = await httpClient.getUrl(url);
      final HttpClientResponse response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        final String json = await response.transform(utf8.decoder).join();
        result = 'result from approve id function: $json';

        return Future.value(true);
      } else {
        result =
        'Error sending approve id email:\nHttp status: ${response.statusCode}}';
        log('result from sending approve id email: $result');
        return Future.value(false);
      }
    } catch (exception) {
      result = 'Failed sending approve id email.';
      log(exception.toString());
      log('result from sending approve id email: $result');
      return Future.value(false);
    }

  }
}
