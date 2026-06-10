import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDHIxYoV_YNP32VUkGpLUAdUG2SZc6yGs4',
    appId: '1:314097255611:android:4376dc3417c076ec5f159e',
    messagingSenderId: '314097255611',
    projectId: 'social-app-9efa5',
    storageBucket: 'social-app-9efa5.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB19fBaJAbX06qav0hina0S6wCd0wUu5dY',
    appId: '1:314097255611:ios:6c3abe8c6b2fcf1a5f159e',
    messagingSenderId: '314097255611',
    projectId: 'social-app-9efa5',
    storageBucket: 'social-app-9efa5.firebasestorage.app',
    iosBundleId: 'com.socialapp.socialApp',
  );

  // Replace all values below with your real Firebase project config.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDHIxYoV_YNP32VUkGpLUAdUG2SZc6yGs4',
    appId: '1:314097255611:android:4376dc3417c076ec5f159e',
    messagingSenderId: '314097255611',
    projectId: 'social-app-9efa5',
    authDomain: 'your-project-id.firebaseapp.com',
    storageBucket: 'your-project-id.appspot.com',
  );

}