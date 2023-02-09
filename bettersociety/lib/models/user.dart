import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String username;
  final String email;
  final String bio;
  final String photoUrl;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.bio,
    required this.photoUrl,
  });

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    return UserModel(
      id: doc['id'],
      username: doc['username'],
      email: doc['email'],
      bio: doc['bio'],
      photoUrl: doc['photoUrl'],
    );
  }

}
