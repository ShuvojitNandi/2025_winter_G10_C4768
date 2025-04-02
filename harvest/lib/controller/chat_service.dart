import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../model/message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final String userEmail = FirebaseAuth.instance.currentUser!.email!;

  String _generateChatId(String userId, String peerId) {
    return userId.compareTo(peerId) < 0
        ? '${userId}_$peerId'
        : '${peerId}_$userId';
  }

  Future<void> sendMessage(
      DocumentSnapshot peer, String message) async {
    final chatId = _generateChatId(userId, peer.id);

    Message newMessage = Message(
      senderId: userId,
      senderEmail: userEmail,
      receiverId: peer.id,
      receiverEmail: peer['email'],
      chatId: chatId,
      text: message,
      timestamp: Timestamp.now()
    );

    final chatroomRef = _firestore.collection('chatrooms').doc(chatId);

    await _firestore
      .collection('chatrooms')
      .doc(chatId)
      .collection('messages')
      .add(newMessage.toMap());

    // Update unread count for the receiver
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final chatroomDoc = await transaction.get(chatroomRef);
      if (!chatroomDoc.exists) {
        transaction.set(chatroomRef, {
          'unreadMessages': {peer.id: 1}
        }, SetOptions(merge: true));
      } else {
        final unreadMessages = chatroomDoc.data()?['unreadMessages'] ?? {};
        int currentUnread = unreadMessages[peer.id] ?? 0;
        transaction.update(chatroomRef, {
          'unreadMessages.${peer.id}': currentUnread + 1,
        });
      }
    });
  }

  getMessages(DocumentSnapshot<Object?> peer) {
    final chatId = _generateChatId(userId, peer.id);

    return _firestore
        .collection('chatrooms')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshots) =>
                snapshots.docs.map((doc) => Message.fromMap(doc)).toList());
  }

}