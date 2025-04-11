import './firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'auth_gate.dart';

import 'controller/messaging_controller.dart' as messaging;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print('Firebase initialized successfully');

    await messaging.init();
    print('Messaging initialized successfully');

    // Wait a moment to ensure everything is ready
    await Future.delayed(const Duration(seconds: 1));
    
    try {
      await messaging.subscribeToTopic("test");
      print('Successfully subscribed to topic "test"');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }

    // Set up message listener
    messaging.foregroundMessageEvent.connect((content) {
      print("title: ${content.notification?.title}");
      print("body: ${content.notification?.body}");
      print("data: ${content.data.toString()}");
    });

    runApp(MainApp());
  } catch (e) {
    print('Failed to initialize Firebase: $e');
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      home: AuthGate(),
    );
  }
}
