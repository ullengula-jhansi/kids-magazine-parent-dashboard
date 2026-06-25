import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC07dKUfXe01cvovZU55n_bHd-055oM65Y',
    appId: '1:793263385393:android:0a8d671a1fc3954bd85e10',
    messagingSenderId: '793263385393',
    projectId: 'kids-magazine-c41d5',
    storageBucket: 'kids-magazine-c41d5.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD8sv7Ij3SKYiGb2HAsbr8PaaIf_9LesTs',
    appId: '1:793263385393:ios:965922a931143673d85e10',
    messagingSenderId: '793263385393',
    projectId: 'kids-magazine-c41d5',
    storageBucket: 'kids-magazine-c41d5.appspot.com',
    androidClientId: '793263385393-1ov80u8sb4ouhnu6lpp8cq38bi23svuo.apps.googleusercontent.com',
    iosClientId: '793263385393-3g684umg7maqq767nt582e8ddh7a4jh6.apps.googleusercontent.com',
    iosBundleId: 'com.example.kidsMagazineV6',
  );

}