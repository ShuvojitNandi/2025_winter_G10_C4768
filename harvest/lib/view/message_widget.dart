import 'package:flutter/material.dart';
import '../model/message.dart';

class MessageWidget extends StatelessWidget {
  final Message message;
  final bool isSent;

  const MessageWidget({super.key, required this.message, required this.isSent});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isSent ? MainAxisAlignment.end: MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: isSent ? Colors.blue[300] : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(message.text),
        )
      ],
    );
  }
}