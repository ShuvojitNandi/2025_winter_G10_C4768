import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:harvest/domain/device_message_request.dart';
import 'package:harvest/model/device_model.dart';
import '../modules/dispatcher.dart';
import '../model/messaging_model.dart' as model;
import '../domain/topic_message_request.dart';

Dispatcher<RemoteMessage> backgroundMessageEvent = Dispatcher();
Dispatcher<RemoteMessage> foregroundMessageEvent = Dispatcher();

Future<void> subscribeToTopic(String topicName) async {
  await FirebaseMessaging.instance.subscribeToTopic(topicName);
  print("Subscribed to topic: $topicName");
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
  backgroundMessageEvent.fire(message);
}

Future<String?> getDeviceToken() async {
  return await model.getDeviceToken();
}

Future<void> sendMessageToTopic(TopicMessageRequest request) async {
  await model.sendMessageToTopic(request);
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
