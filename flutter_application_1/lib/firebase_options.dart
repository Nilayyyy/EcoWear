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
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyA2izg2tieaZXmXraVqIqhbomEv2kO_Uw0',
    appId: '1:583043618177:web:cc7d9db0555441676f4480',
    messagingSenderId: '583043618177',
    projectId: 'safaifirebase',
    authDomain: 'safaifirebase.firebaseapp.com',
    storageBucket: 'safaifirebase.appspot.com',
    measurementId: 'G-D8SW1ZLJ28',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAZN0Tjh06gDQL6iHkGt2kJTQ_tSNWrixU',
    appId: '1:583043618177:android:6761ed448d0ade796f4480',
    messagingSenderId: '583043618177',
    projectId: 'safaifirebase',
    storageBucket: 'safaifirebase.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCLVIEyRcXDeRjAQRDQ8u5TE3ijfvmur_o',
    appId: '1:583043618177:ios:34d797e411024ba36f4480',
    messagingSenderId: '583043618177',
    projectId: 'safaifirebase',
    storageBucket: 'safaifirebase.appspot.com',
    iosBundleId: 'com.example.flutterApplication1',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCLVIEyRcXDeRjAQRDQ8u5TE3ijfvmur_o',
    appId: '1:583043618177:ios:34d797e411024ba36f4480',
    messagingSenderId: '583043618177',
    projectId: 'safaifirebase',
    storageBucket: 'safaifirebase.appspot.com',
    iosBundleId: 'com.example.flutterApplication1',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA2izg2tieaZXmXraVqIqhbomEv2kO_Uw0',
    appId: '1:583043618177:web:e4840bdcaaac71786f4480',
    messagingSenderId: '583043618177',
    projectId: 'safaifirebase',
    authDomain: 'safaifirebase.firebaseapp.com',
    storageBucket: 'safaifirebase.appspot.com',
    measurementId: 'G-0YWS15X8T9',
  );
}