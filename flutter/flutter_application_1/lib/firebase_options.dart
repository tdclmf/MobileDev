import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions? get currentPlatform {
    const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
    const appId = String.fromEnvironment('FIREBASE_APP_ID');
    const senderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
    const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
    const databaseUrl = String.fromEnvironment('FIREBASE_DATABASE_URL');

    if (apiKey.isEmpty ||
        appId.isEmpty ||
        senderId.isEmpty ||
        projectId.isEmpty ||
        databaseUrl.isEmpty) {
      return null;
    }
    return const FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: senderId,
      projectId: projectId,
      databaseURL: databaseUrl,
      authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
      storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
    );
  }
}
