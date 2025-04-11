class DeviceMessageRequest {
  String? body;
  String? title;
  String device;

  DeviceMessageRequest(this.device, {this.title, this.body});
}
