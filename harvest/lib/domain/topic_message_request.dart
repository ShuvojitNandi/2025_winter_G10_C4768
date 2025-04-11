class TopicMessageRequest {
  String? body;
  String? title;
  String topic;

  TopicMessageRequest(this.topic, {this.title, this.body});
}
