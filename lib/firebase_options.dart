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
    apiKey: 'AIzaSyAAaLM_BpFn2Dq5TWx0ZNGMs-rRDfnN9RQ',
    appId: '1:653163148847:web:03c3a458a6d56513ed38da',
    messagingSenderId: '653163148847',
    projectId: 'chat-app-83509',
    authDomain: 'chat-app-83509.firebaseapp.com',
    storageBucket: 'chat-app-83509.appspot.com',
    measurementId: 'G-7JGL3Z6P4F',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCE-D401uNpkXhmkN9KCPo1EOQHJR82syc',
    appId: '1:653163148847:android:ef44f9698642a911ed38da',
    messagingSenderId: '653163148847',
    projectId: 'chat-app-83509',
    storageBucket: 'chat-app-83509.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCtkimHw-A1yPa4RLIB15P2D4oY3GCeQr0',
    appId: '1:653163148847:ios:a2fc23cc4a603a88ed38da',
    messagingSenderId: '653163148847',
    projectId: 'chat-app-83509',
    storageBucket: 'chat-app-83509.appspot.com',
    iosBundleId: 'com.example.chartApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCtkimHw-A1yPa4RLIB15P2D4oY3GCeQr0',
    appId: '1:653163148847:ios:fc32b21fb4eca3eded38da',
    messagingSenderId: '653163148847',
    projectId: 'chat-app-83509',
    storageBucket: 'chat-app-83509.appspot.com',
    iosBundleId: 'com.example.chartApp.RunnerTests',
  );
}