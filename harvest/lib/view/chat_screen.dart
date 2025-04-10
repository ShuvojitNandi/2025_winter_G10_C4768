
import 'package:flutter/material.dart';
import '../model/message.dart';
import 'message_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controller/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final DocumentSnapshot peer;

  const ChatScreen({super.key, required this.peer});

  @override
  State<ChatScreen> createState() {
    return _ChatScreenState();
  }
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late ChatService _chatService;
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    _chatService = ChatService();
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with: ${widget.peer['name']}"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<List<Message>>(
                  stream: _chatService.getMessages(widget.peer),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      print("all messages snapshot error: ${snapshot.error}");
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final messages = snapshot.data!;
                    return ListView.builder(
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isSent =
                            message.senderId == _auth.currentUser!.uid;

                        return MessageWidget(message: message, isSent: isSent);
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            icon: Icon(Icons.send),
                            onPressed: () async {
                              await _chatService.sendMessage(
                                widget.peer,
                                _messageController.text,
                              );
                              _messageController.clear();
                            },
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
