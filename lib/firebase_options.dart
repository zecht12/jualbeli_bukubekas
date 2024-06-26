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
    apiKey: 'AIzaSyDRFkRxHkMwDk-6ltP79EpnlZNeNwyrAdQ',
    appId: '1:587417618994:web:177a0c580f246b4c5b8a2b',
    messagingSenderId: '587417618994',
    projectId: 'jual-beli-buku-bekas',
    authDomain: 'jual-beli-buku-bekas.firebaseapp.com',
    storageBucket: 'jual-beli-buku-bekas.appspot.com',
    measurementId: 'G-CTBG7S61VJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCcXDKDMp2zBCjyxs5yutW6pPyqy6hWIJY',
    appId: '1:587417618994:android:f91325717845a4265b8a2b',
    messagingSenderId: '587417618994',
    projectId: 'jual-beli-buku-bekas',
    storageBucket: 'jual-beli-buku-bekas.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyASwFZbde55UFubH_1vRr3lwucPXSJtgw4',
    appId: '1:587417618994:ios:9a45a09a898714785b8a2b',
    messagingSenderId: '587417618994',
    projectId: 'jual-beli-buku-bekas',
    storageBucket: 'jual-beli-buku-bekas.appspot.com',
    iosBundleId: 'com.example.jualbeliBukuBekas',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyASwFZbde55UFubH_1vRr3lwucPXSJtgw4',
    appId: '1:587417618994:ios:9a45a09a898714785b8a2b',
    messagingSenderId: '587417618994',
    projectId: 'jual-beli-buku-bekas',
    storageBucket: 'jual-beli-buku-bekas.appspot.com',
    iosBundleId: 'com.example.jualbeliBukuBekas',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDRFkRxHkMwDk-6ltP79EpnlZNeNwyrAdQ',
    appId: '1:587417618994:web:f9ef9c57720ff9ae5b8a2b',
    messagingSenderId: '587417618994',
    projectId: 'jual-beli-buku-bekas',
    authDomain: 'jual-beli-buku-bekas.firebaseapp.com',
    storageBucket: 'jual-beli-buku-bekas.appspot.com',
    measurementId: 'G-H3CG29M1N1',
  );
}
