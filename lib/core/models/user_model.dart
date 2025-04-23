class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final DateTime? lastSeen;
  final bool isOnline;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.lastSeen,
    this.isOnline = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profileImage: map['profileImage'],
      lastSeen: map['lastSeen'] != null
          ? (map['lastSeen'] as dynamic).toDate()
          : null,
      isOnline: map['isOnline'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'lastSeen': lastSeen,
      'isOnline': isOnline,
    };
  }
}