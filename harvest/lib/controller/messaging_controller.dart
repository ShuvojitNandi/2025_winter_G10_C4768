import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import '../modules/dispatcher.dart';
import '../model/messaging_model.dart' as model;
import '../domain/topic_message_request.dart';

Dispatcher<RemoteMessage> backgroundMessageEvent = Dispatcher();
Dispatcher<RemoteMessage> foregroundMessageEvent = Dispatcher();

// validate topic name according to FCM Requirements
bool _isValidTopicName(String topicName) {
  final validTopicRegex = RegExp(r'^[a-zA-Z0-9-_.~%]+$');
  return validTopicRegex.hasMatch(topicName) &&
      topicName.length <= 50 &&  // FCM topic length limit
      !topicName.startsWith('__');  // Reserved prefix
}


Future<void> subscribeToTopic(String topicName) async {
  try{
    if(!_isValidTopicName(topicName)) {
      throw Exception('Invalid topic Name: $topicName - must match[a-zA-Z0-9-_.~%] and be <= 50 chars');
    }

    // Ensure we have a valid FCM token first
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) {
      throw Exception('No FCM token available');
    }

    print('Attempting to subscribe to topic: $topicName with token: $token');
    await FirebaseMessaging.instance.subscribeToTopic(topicName);
    print("Successfully Subscribed to topic: $topicName");
  }catch(e, stackTrace) {
    print('Error subscribing to topic $topicName: $e');
    print('stack trace: $stackTrace');
    rethrow;
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    print("Handling a background message: ${message.messageId}");
    backgroundMessageEvent.fire(message);
  } catch (e, stackTrace) {
    print('Error in background handler: $e');
    print('Stack trace: $stackTrace');
  }
}

Future<String?> getDeviceToken() async {
  try {
    final token = await model.getDeviceToken();
    print('Current FCM token: $token');
    return token;
  } catch (e) {
    print('Error getting device token: $e');
    return null;
  }
}

Future<void> sendMessageToTopic(TopicMessageRequest request) async {
  try {
    print('Sending message to topic: ${request.topic}');
    await model.sendMessageToTopic(request);
    print('Message sent successfully');
  } catch (e) {
    print('Error sending message: $e');
    rethrow;
  }
}

Future<void> init() async {
  try {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: true,
      sound: true,
    );
    print('Notification permissions: ${settings.authorizationStatus}');

    // Token handling with more robust logging
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      print("New FCM token generated: $fcmToken");
      // Consider adding token refresh handling logic here
    }).onError((err) {
      print("FCM token refresh error: $err");
    });

    // Get initial token
    final initialToken = await FirebaseMessaging.instance.getToken();
    print('Initial FCM token: $initialToken');

    // Foreground message handling
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message received:');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
      foregroundMessageEvent.fire(message);
    });

    // Background message handling
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print('App opened from terminated state with message:');
      print('Title: ${initialMessage.notification?.title}');
      print('Body: ${initialMessage.notification?.body}');
    }

    print('Firebase Messaging initialized successfully');

  } catch (e, stackTrace) {
    print('Error initializing Firebase Messaging: $e');
    print('Stack trace: $stackTrace');
    rethrow;
  }
  //await FirebaseMessaging.instance.requestPermission(provisional: true);

  // FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
  //   print("Change detected in fcm token");
  // }).onError((err) {
  //   print("Error with fcm token");
  // });

  // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   print("Message received: ${message.notification?.title}");
  //   foregroundMessageEvent.fire(message);
  // });

  // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}
