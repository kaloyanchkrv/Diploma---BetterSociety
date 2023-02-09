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
    apiKey: 'AIzaSyDiQ-WYZ-fpVGHDkyoybJEqghrol3_09oE',
    appId: '1:175760544897:web:8d1014ab76048a8348a980',
    messagingSenderId: '175760544897',
    projectId: 'bettersociety-83e83',
    authDomain: 'bettersociety-83e83.firebaseapp.com',
    storageBucket: 'bettersociety-83e83.appspot.com',
    measurementId: 'G-VNNP9JDNL0',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA1yJftD2K3sD43f6X8eFpxQtxT8_mAmRo',
    appId: '1:175760544897:android:292c347d76180f4a48a980',
    messagingSenderId: '175760544897',
    projectId: 'bettersociety-83e83',
    storageBucket: 'bettersociety-83e83.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB2yNH8ruSfU-2jbaJFjwZCYSZ50LsDEvc',
    appId: '1:175760544897:ios:97cd15a5a38e02fe48a980',
    messagingSenderId: '175760544897',
    projectId: 'bettersociety-83e83',
    storageBucket: 'bettersociety-83e83.appspot.com',
    androidClientId: '175760544897-i4qjfithfvegd16hl999iq1klmp909p5.apps.googleusercontent.com',
    iosClientId: '175760544897-g0poodh1oii5g3sn7hs6j04vlvtth9mc.apps.googleusercontent.com',
    iosBundleId: 'com.example.bettersociety',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB2yNH8ruSfU-2jbaJFjwZCYSZ50LsDEvc',
    appId: '1:175760544897:ios:97cd15a5a38e02fe48a980',
    messagingSenderId: '175760544897',
    projectId: 'bettersociety-83e83',
    storageBucket: 'bettersociety-83e83.appspot.com',
    androidClientId: '175760544897-i4qjfithfvegd16hl999iq1klmp909p5.apps.googleusercontent.com',
    iosClientId: '175760544897-g0poodh1oii5g3sn7hs6j04vlvtth9mc.apps.googleusercontent.com',
    iosBundleId: 'com.example.bettersociety',
  );
}
