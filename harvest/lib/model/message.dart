import 'package:cloud_firestore/cloud_firestore.dart';

class Message{
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String receiverEmail;
  final String chatId;
  final String text;
  final Timestamp timestamp;

  Message({
    required this.senderId,
    required this.senderEmail,
    required this.receiverId,
    required this.receiverEmail,
    required this.chatId,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'receiverEmail': receiverEmail,
      'chatId': chatId,
      'text': text,
      'timestamp': timestamp,
    };
  }

  static Message fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Message(
      senderId: data['senderId'],
      senderEmail: data['senderEmail'],
      receiverId: data['receiverId'],
      text: data['text'],
      timestamp: data['timestamp'],
      receiverEmail: data['receiverEmail'],
      chatId: data['chatId'],
    );
  }

}