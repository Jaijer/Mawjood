import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

// Initialize Firebase
class FirebaseConfig {
  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        // You may need these options for web platforms
        options: kIsWeb
            ? const FirebaseOptions(
            apiKey: "AIzaSyC4K4tEPW0bTPSKqsMTxzSmny6Un9DGDX0",
            authDomain: "mawjood-85dea.firebaseapp.com",
            projectId: "mawjood-85dea",
            storageBucket: "mawjood-85dea.firebasestorage.app",
            messagingSenderId: "525840465634",
            appId: "1:525840465634:web:853c7dc4ccf6be844ce8bb",
            measurementId: "G-T7ZTHZTF0N"
        )
            : null, // For mobile, Firebase will use google-services.json or GoogleService-Info.plist
      );
      print('Firebase initialized successfully');
    } catch (e) {
      print('Error initializing Firebase: $e');
    }
  }
}