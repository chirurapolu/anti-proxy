import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, faculty, student }

class UserModel {
  final String userId;
  final String name;
  final UserRole role;
  final String? section;
  final String? photoUrl;
  final String? email;
  final String? authUid;
  final DateTime createdAt;

  UserModel({
    required this.userId,
    required this.name,
    required this.role,
    this.section,
    this.photoUrl,
    this.email,
    this.authUid,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['user_id'] ?? '',
      name: map['name'] ?? '',
      role: UserRole.values.firstWhere((e) => e.name == map['role']),
      section: map['section'],
      photoUrl: map['photo_url'],
      email: map['email'],
      authUid: map['auth_uid'],
      createdAt: (map['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'role': role.name,
      'section': section,
      'photo_url': photoUrl,
      'email': email,
      'auth_uid': authUid,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
