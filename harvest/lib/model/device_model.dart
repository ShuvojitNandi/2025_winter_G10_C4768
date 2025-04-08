class DeviceModel {
  final String uid;
  final String? token;

  DeviceModel({
    required this.uid,
    this.token,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'token': token,
    };
  }

  factory DeviceModel.fromMap(Map<String, dynamic> map) {
    return DeviceModel(
      uid: map['uid'],
      token: map['token'],
    );
  }
}
