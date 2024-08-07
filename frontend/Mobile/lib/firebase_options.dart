// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDfUdIArclKcGQs9u7EPMkseWZFOCXQUbk',
    appId: '1:756177572893:web:6f10e051e43a5da87662f4',
    messagingSenderId: '756177572893',
    projectId: 'church-reservation-e7dea',
    authDomain: 'church-reservation-e7dea.firebaseapp.com',
    storageBucket: 'church-reservation-e7dea.appspot.com',
    measurementId: 'G-WMVD3HKZ5E',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCSGYRjxv3RkIu4e2y99UbblImKGiAljbo',
    appId: '1:756177572893:android:8d12d261d0b414e77662f4',
    messagingSenderId: '756177572893',
    projectId: 'church-reservation-e7dea',
    storageBucket: 'church-reservation-e7dea.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB08qNtDdLTXcGThDWijQ2kx1GSxU2PCZg',
    appId: '1:756177572893:ios:a830332b147f1b127662f4',
    messagingSenderId: '756177572893',
    projectId: 'church-reservation-e7dea',
    storageBucket: 'church-reservation-e7dea.appspot.com',
    iosBundleId: 'com.example.church',
  );
}
