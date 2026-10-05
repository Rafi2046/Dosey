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
    apiKey: 'AIzaSyDpvxXYwlwZfncPg_ivAVYEGjYv3wd3zKg',
    appId: '1:918524133674:android:003fc84db793dec0b7de53',
    messagingSenderId: '918524133674',
    projectId: 'dosey-502ae',
    authDomain: 'dosey-502ae.firebaseapp.com',
    storageBucket: 'dosey-502ae.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDpvxXYwlwZfncPg_ivAVYEGjYv3wd3zKg',
    appId: '1:918524133674:android:003fc84db793dec0b7de53',
    messagingSenderId: '918524133674',
    projectId: 'dosey-502ae',
    storageBucket: 'dosey-502ae.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyApswYzKrkWS3MrwfPkPsSeVCEOWN4fhjc',
    appId: '1:918524133674:ios:c49902ee030fc4ccb7de53',
    messagingSenderId: '918524133674',
    projectId: 'dosey-502ae',
    storageBucket: 'dosey-502ae.firebasestorage.app',
    iosClientId:
        '918524133674-gajiev6rg9o88ofbf606pm5cbfj7arad.apps.googleusercontent.com',
    iosBundleId: 'com.onesttech.dosey',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyApswYzKrkWS3MrwfPkPsSeVCEOWN4fhjc',
    appId: '1:918524133674:ios:c49902ee030fc4ccb7de53',
    messagingSenderId: '918524133674',
    projectId: 'dosey-502ae',
    storageBucket: 'dosey-502ae.firebasestorage.app',
    iosClientId:
        '918524133674-gajiev6rg9o88ofbf606pm5cbfj7arad.apps.googleusercontent.com',
    iosBundleId: 'com.onesttech.dosey',
  );
}
