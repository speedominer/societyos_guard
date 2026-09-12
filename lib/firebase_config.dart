// Firebase config placeholder file. Use this to wire platform-specific Firebase initialization.
import 'config.dart';

class FirebaseConfig {
  static Map<String, String> get options {
    return Map<String, String>.from(Config.firebaseOptions.map((k, v) => MapEntry(k, v.toString())));
  }
}
