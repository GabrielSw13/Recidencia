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
    apiKey: 'AIzaSyCYHdrcTLN9uEE6797iBOrJHttrYIFdDLE',
    appId: '1:629732481128:web:2ed633eb075eb2c2eac3dd',
    messagingSenderId: '629732481128',
    projectId: 'residencia-c76f8',
    authDomain: 'residencia-c76f8.firebaseapp.com',
    storageBucket: 'residencia-c76f8.firebasestorage.app',
    measurementId: 'G-9SZE2K2Z33',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBXHAhe5OY8nigoeFNs_6LAJQrZmbHk9hE',
    appId: '1:629732481128:android:775a3abc147bdc63eac3dd',
    messagingSenderId: '629732481128',
    projectId: 'residencia-c76f8',
    storageBucket: 'residencia-c76f8.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD2-wtyomjPlbz7Q4LL-e1PTyoJ8o2km58',
    appId: '1:629732481128:ios:667eb52ed1b53159eac3dd',
    messagingSenderId: '629732481128',
    projectId: 'residencia-c76f8',
    storageBucket: 'residencia-c76f8.firebasestorage.app',
    iosBundleId: 'com.example.apptienda',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD2-wtyomjPlbz7Q4LL-e1PTyoJ8o2km58',
    appId: '1:629732481128:ios:667eb52ed1b53159eac3dd',
    messagingSenderId: '629732481128',
    projectId: 'residencia-c76f8',
    storageBucket: 'residencia-c76f8.firebasestorage.app',
    iosBundleId: 'com.example.apptienda',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCYHdrcTLN9uEE6797iBOrJHttrYIFdDLE',
    appId: '1:629732481128:web:02f77c43c0731e0eeac3dd',
    messagingSenderId: '629732481128',
    projectId: 'residencia-c76f8',
    authDomain: 'residencia-c76f8.firebaseapp.com',
    storageBucket: 'residencia-c76f8.firebasestorage.app',
    measurementId: 'G-6E3ZHL278H',
  );
}