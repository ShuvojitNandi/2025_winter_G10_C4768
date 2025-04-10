import 'package:flutter/material.dart';
import '../domain/topic_message_request.dart';
import '../controller/messaging_controller.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();


  Future<void> _sendNotification(String title, String body) async {
    TopicMessageRequest request = TopicMessageRequest("test", title:title, body:body);
    sendMessageToTopic(request);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Notification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Notification Title'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _bodyController,
              decoration: InputDecoration(labelText: 'Notification Body'),
              maxLines: 5, // Allow multiple lines
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final title = _titleController.text;
                final body = _bodyController.text;
                if (title.isNotEmpty && body.isNotEmpty) {
                  _sendNotification(title, body);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Notification sent!')),
                  );
                  _titleController.clear();
                  _bodyController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter title and body.')),
                  );
                }
              },
              child: Text('Send Notification'),
            ),
          ],
        ),
      ),
    );
  }
}