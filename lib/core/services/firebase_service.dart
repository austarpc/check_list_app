import 'package:firebase_core/firebase_core.dart';
import 'package:muhasabat/firebase_options.dart';

class FirebaseService {
  FirebaseService._();

  static bool _initialized = false;
  static bool get isInitialized => _initialized && Firebase.apps.isNotEmpty;

  static Future<void> initialize() async {
    if (Firebase.apps.isNotEmpty) {
      _initialized = true;
      return;
    }
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _initialized = true;
  }
}
