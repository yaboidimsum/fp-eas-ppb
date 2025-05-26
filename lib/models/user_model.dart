class UserModel {
  final String uid;
  final String email;
  final String name;
  final String? fcmToken; // Add FCM token field

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.fcmToken, // Optional during creation, can be updated later
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'fcmToken': fcmToken, // Include in map
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      fcmToken: map['fcmToken'], // Get from map
    );
  }

  // Add a method to update the FCM token
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? fcmToken,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
