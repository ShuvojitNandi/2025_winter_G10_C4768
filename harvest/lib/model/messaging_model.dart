import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:harvest/model/device_model.dart';
import 'package:http/http.dart' as http;
import '../domain/device_message_request.dart';
import '../domain/topic_message_request.dart';

class DeviceManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<void> setUserDeviceToken(DeviceModel device) async {
    try {
      await _firestore
          .collection('devices')
          .doc(device.uid)
          .set(device.toMap());
    } catch (e) {
      print("Error adding device: $e");
    }
  }

  Future<String?> getDeviceTokenFromUser(String uid) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('devices').doc(uid).get();

    if (userDoc.exists) {
      final data = userDoc.data() as Map<String, dynamic>;
      return data['device'] as String?;
    }
    return null;
  }
}

Future<String?> getDeviceToken() async {
  final apnsToken = await FirebaseMessaging.instance.getToken();

  if (apnsToken != null) {
    return apnsToken;
  }

  return null;
}

String getBaseURL() {
  return "https://us-central1-harvest-587ba.cloudfunctions.net/api";
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
