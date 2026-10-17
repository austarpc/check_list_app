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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDp_tV98twaDq9qEhnrrrXlKr1FcqHm1HU',
    appId: '1:1083781579807:web:fdaf161be38dcaf833812a',
    messagingSenderId: '1083781579807',
    projectId: 'arpc-checklist',
    databaseURL: 'https://arpc-checklist-default-rtdb.asia-southeast1.firebasedatabase.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC14Dnwm5EK6TpqH4PnVzStfXLwINxZPWY',
    appId: '1:1083781579807:android:89bf1ce934fc583033812a',
    messagingSenderId: '1083781579807',
    projectId: 'arpc-checklist',
    databaseURL: 'https://arpc-checklist-default-rtdb.asia-southeast1.firebasedatabase.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDMuGLr_Xq85Jt72zNEE4efXfIxE3EzCok',
    appId: '1:1083781579807:ios:962588126eebab0933812a',
    messagingSenderId: '1083781579807',
    projectId: 'arpc-checklist',
    databaseURL: 'https://arpc-checklist-default-rtdb.asia-southeast1.firebasedatabase.app',
  );
}
