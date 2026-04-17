import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String? profilePicture;
  final String? username;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.profilePicture,
    this.username,
    this.createdAt,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      firstName: data['FirstName'] ?? '',
      lastName: data['LastName'] ?? '',
      email: data['Email'] ?? '',
      phoneNumber: data['PhoneNumber'],
      profilePicture: data['ProfilePicture'],
      username: data['Username'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}