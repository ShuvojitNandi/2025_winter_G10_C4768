import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:harvest/domain/device_message_request.dart';
import 'package:harvest/model/device_model.dart';
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

Future<void> sendMessageToDevice(DeviceMessageRequest request) async {
  await model.sendMessageToDevice(request);
}

Future<DeviceMessageRequest?> createDeviceMessageFromUID(String uid,
    {String? title, String? body}) async {
  String? device = await model.DeviceManager().getDeviceTokenFromUser(uid);

  if (device == null) return null;

  return DeviceMessageRequest(device, title: title, body: body);
}

Future<void> bindToken(String uid) async {
  model.DeviceManager manager = model.DeviceManager();
  String? token = await getDeviceToken();

  DeviceModel device = DeviceModel(uid: uid, token: token);
  await manager.setUserDeviceToken(device);
}

Future<void> init() async {
  await FirebaseMessaging.instance.requestPermission(provisional: true);

  model.DeviceManager manager = model.DeviceManager();
  String? uid = manager.currentUserId;

  if (uid != null) {
    await bindToken(uid);
  }

  FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
    print("Change detected in fcm token");
  }).onError((err) {
    print("Error with fcm token");
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Message received: ${message.notification?.title}");
    foregroundMessageEvent.fire(message);
  });

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}
