import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import '../domain/device_message_request.dart';
import '../domain/topic_message_request.dart';

Future<String?> getDeviceToken() async {
  final apnsToken = await FirebaseMessaging.instance.getToken();

  if (apnsToken != null) {
    return apnsToken;
  }

  return null;
}

String getBaseURL() {
  return "http://172.18.224.1:3000";
}

Future<http.Response> sendMessageToTopic(TopicMessageRequest request) async {
  String apiUrl = "${getBaseURL()}/api/message/topic/${request.topic}";

  return await http.post(
    Uri.parse(apiUrl),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({"title": request.title, "body": request.body}),
  );
}

Future<http.Response> sendMessageToDevice(DeviceMessageRequest request) async {
  String apiUrl = "${getBaseURL()}/api/message/device/${request.device}";

  return await http.post(
    Uri.parse(apiUrl),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({"title": request.title, "body": request.body}),
  );
}
