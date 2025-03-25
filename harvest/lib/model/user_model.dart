class UserModel {
  final String? uid;
  final String name;
  final String email;
  final String? profileImageUrl;
  final List<String>? shops;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.shops,
  });

  
  Map<String, dynamic> toMap() {
    return {
      'uid':uid,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'shops': shops,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? 'Unknown',
      email: map['email'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      shops: List<String>.from(map['shops'] ?? []),
    );
  }
}
