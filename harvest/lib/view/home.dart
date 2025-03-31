import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../controller/messaging_controller.dart' as controller;
import '../domain/topic_message_request.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textController = TextEditingController();

  List<String> messages = [];

  Future<void> signout() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> submit() async {
    TopicMessageRequest request =
        TopicMessageRequest("test", title: _textController.text);
    _textController.text = "";

    await controller.sendMessageToTopic(request);
  }

  addMessage(String? message) {
    if (message == null) return;

    setState(() {
      messages.add(message);
    });
  }

  @override
  void initState() {
    super.initState();
    controller.foregroundMessageEvent.connect((message) {
      addMessage(message.notification?.title);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
          actions: [IconButton(onPressed: signout, icon: Icon(Icons.logout))],
        ),
        body: Container(
          color: Colors.white,
          child: Column(
            children: [
              Expanded(
                  child: Container(
                      color:
                          Color.from(alpha: 1, red: .85, green: .85, blue: .85),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: List.generate(messages.length, (i) {
                                return Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(4))),
                                  width: double.infinity,
                                  margin: EdgeInsets.fromLTRB(4, 0, 4, 8),
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    messages[i],
                                    style: TextStyle(color: Colors.black),
                                  ),
                                );
                              }),
                            ),
                          )
                        ],
                      ))),
              Container(
                margin: EdgeInsets.fromLTRB(0, 4, 0, 128),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                        child: TextFormField(
                      controller: _textController,
                      minLines: 1,
                      maxLines: 5,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: "Enter Text",
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (text) {
                        setState(() {});
                      },
                    )),
                    IconButton(onPressed: submit, icon: Icon(Icons.send))
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
