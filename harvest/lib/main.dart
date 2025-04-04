import './firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'auth_gate.dart';

import 'controller/messaging_controller.dart' as messaging;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await messaging.init();
  await messaging.subscribeToTopic("test");

  messaging.foregroundMessageEvent.connect((content) {
    print("title: ${content.notification?.title}");
    print("body: ${content.notification?.body}");
    print("data: ${content.data.toString()}");
  });

  runApp(MainApp());
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
