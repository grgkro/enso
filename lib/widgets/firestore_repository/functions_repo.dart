
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import '../service_locator.dart';
import '../services/global_service.dart';

GlobalService _globalService = getIt<GlobalService>();

class FunctionsRepo {
  Future<void> sendVerificationEmail(String? uid) async {
    String url = 'https://us-central1-enso-fairleih.cloudfunctions.net/email';
    String? userId;
    if (uid != null) {
      userId = uid;
    } else if (_globalService.currentUser?.uid != null) {
      userId = _globalService.currentUser?.uid;
    } else {
      log("Can't send the confirmation email without a uid");
      return;
    }
    url += '?userId=' + userId!;
    final HttpClient httpClient = new HttpClient();

    String result;
    try {
      final HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
      final HttpClientResponse response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        final String json = await response.transform(utf8.decoder).join();
        result = 'result from email function: $json';
      } else {
        result =
            'Error sending confirmation email:\nHttp status: ${response.statusCode}}';
      }
    } catch (exception) {
      result = 'Failed sending confirmation email.';
      log(exception.toString());
    }
    log('result from sending verification email: $result');
  }
}
