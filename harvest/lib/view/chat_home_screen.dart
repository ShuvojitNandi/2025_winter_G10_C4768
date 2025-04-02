import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'chat_screen.dart';

class ChatHomeScreen extends StatefulWidget {

  const ChatHomeScreen({Key? key}) : super(key: key);

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: const Text('Messages'),

      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (!snapshot.hasData){
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context,index) {
              var user = snapshot.data!.docs[index];
              if (user['uid'] == FirebaseAuth.instance.currentUser!.uid) {
                return const SizedBox.shrink();
              }
              return FutureBuilder<int>(
                future: _getUnreadMessageCount(currentUserUid, user['uid']),
                builder: (context, unreadSnapshot) {
                  int unreadCount = unreadSnapshot.data ?? 0;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(width: 10),
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: user['profileImageUrl'] != null && user['profileImageUrl']!.isNotEmpty
                                ? NetworkImage(user['profileImageUrl']!)
                                : null,
                            child: (user['profileImageUrl'] == null || user['profileImageUrl']!.isEmpty)
                                ? const Icon(Icons.person, size: 30)
                                : null,
                          ),
                          Expanded(
                            child: ListTile(
                              title: Text(user['name']),
                              subtitle: Text(user['email']),
                              trailing: unreadCount > 0
                                  ? CircleAvatar(
                                backgroundColor: Colors.red,
                                radius: 13,
                                child: Text(
                                  unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              )
                                  : null,
                              onTap: () async {
                                await _resetUnreadMessages(currentUserUid, user['uid']);
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(peer: user),
                                  ),
                                );
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                      const Divider(
                        color: Colors.blueGrey,
                        thickness: 1,
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _generateChatId(String userId, String peerId) {
    return userId.compareTo(peerId) < 0
        ? '${userId}_$peerId'
        : '${peerId}_$userId';
  }

  Future<int> _getUnreadMessageCount(String currentUserUid, String peerUid) async {
    final chatId = _generateChatId(currentUserUid, peerUid);
    final doc = await FirebaseFirestore.instance.collection('chatrooms').doc(chatId).get();
    if (doc.exists && doc.data()!.containsKey('unreadMessages') && doc.data()!['unreadMessages'].containsKey(currentUserUid)) {
      return doc.data()!['unreadMessages'][currentUserUid];
    }
    return 0;
  }

  Future<void> _resetUnreadMessages(String currentUserUid, String peerUid) async {
    final chatId = _generateChatId(currentUserUid, peerUid);
    try{
      final chatroomDoc = await FirebaseFirestore.instance.collection('chatrooms').doc(chatId).get();
      if (chatroomDoc.exists) {
        await FirebaseFirestore.instance.collection('chatrooms').doc(chatId).update({
          'unreadMessages.$currentUserUid': 0,
        });
      } else {
        // Collection not found or document doesn't exist.
        print('Chatroom document not found for chatId: $chatId');
        // Optionally, you can create the document or handle this case differently.
      }
    }catch (e) {
      // Handle any potential errors during the update process.
      print('Error resetting unread messages: $e');
      // Optionally, show an error message to the user.
    }

  }
}



