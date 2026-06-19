import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyD0SpW12OXw2pgby5b9_JmwhxFZa2hmbq8',
    appId: '1:651190719612:web:5529ab044a2612b915a5f9',
    messagingSenderId: '651190719612',
    projectId: 'food-app-3dd8b',
    authDomain: 'food-app-3dd8b.firebaseapp.com',
    storageBucket: 'food-app-3dd8b.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyASm0szAC6S8sjFpF-Lof1ezaYZethqI7w',
    appId: '1:651190719612:android:6d14bf0f4493f32115a5f9',
    messagingSenderId: '651190719612',
    projectId: 'food-app-3dd8b',
    storageBucket: 'food-app-3dd8b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCW-bpsrlujFSbQz3h9cJXAjL9Iig9mgls',
    appId: '1:651190719612:ios:bfe7475434a25eb615a5f9',
    messagingSenderId: '651190719612',
    projectId: 'food-app-3dd8b',
    storageBucket: 'food-app-3dd8b.firebasestorage.app',
    iosBundleId: 'com.kk.FoodDeliveryAppProject',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAOpV45L5sg1frE-V_uVvX1mCOZ3sOP5k0',
    appId: '1:837932087490:ios:260f37d984b98b5688235b',
    messagingSenderId: '837932087490',
    projectId: 'food-delivery-app-6bfc2',
    storageBucket: 'food-delivery-app-6bfc2.appspot.com',
    iosBundleId: 'com.example.FoodDeliveryAppProject.RunnerTests',
  );
}