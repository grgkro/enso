// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA6BTkZBftTSUGxVNXTiE3r4IxnHJ19P_E',
    appId: '1:1088121679666:web:54433dff202454cc42f12b',
    messagingSenderId: '1088121679666',
    projectId: 'enso-fairleih',
    authDomain: 'enso-fairleih.firebaseapp.com',
    storageBucket: 'enso-fairleih.appspot.com',
    measurementId: 'G-4XKSK8FJM5',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAKmJ5rdGEyTF9q-wOUICxsZW9EuSnBWpo',
    appId: '1:1088121679666:android:332ca0215110987542f12b',
    messagingSenderId: '1088121679666',
    projectId: 'enso-fairleih',
    storageBucket: 'enso-fairleih.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBsVeSODF6tvvW1fbYtmavG6z0qqb8oaLs',
    appId: '1:1088121679666:ios:b46307db29e020d042f12b',
    messagingSenderId: '1088121679666',
    projectId: 'enso-fairleih',
    storageBucket: 'enso-fairleih.appspot.com',
    iosClientId: '1088121679666-ns56pste1m7u65katuo2ltaq31ecdc41.apps.googleusercontent.com',
    iosBundleId: 'com.example.ensobox',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBsVeSODF6tvvW1fbYtmavG6z0qqb8oaLs',
    appId: '1:1088121679666:ios:b46307db29e020d042f12b',
    messagingSenderId: '1088121679666',
    projectId: 'enso-fairleih',
    storageBucket: 'enso-fairleih.appspot.com',
    iosClientId: '1088121679666-ns56pste1m7u65katuo2ltaq31ecdc41.apps.googleusercontent.com',
    iosBundleId: 'com.example.ensobox',
  );
}