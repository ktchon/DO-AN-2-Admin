import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String username;
  final String phoneNumber;
  final String profilePicture;
  final String? fcmToken;
  final Timestamp? createdAt; // Giữ Timestamp?
  final dynamic createdAtRaw; // Thêm để debug linh hoạt

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.phoneNumber,
    required this.profilePicture,
    this.fcmToken,
    this.createdAt,
    this.createdAtRaw,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    final rawCreatedAt = map['createdAt'];

    Timestamp? timestamp;
    if (rawCreatedAt is Timestamp) {
      timestamp = rawCreatedAt;
    } else if (rawCreatedAt is String) {
      try {
        timestamp = Timestamp.fromDate(DateTime.parse(rawCreatedAt));
      } catch (_) {
        timestamp = null;
      }
    }

    return UserModel(
      id: id,
      email: map['Email'] ?? '',
      firstName: map['FirstName'] ?? '',
      lastName: map['LastName'] ?? '',
      username: map['Username'] ?? '',
      phoneNumber: map['PhoneNumber'] ?? '',
      profilePicture: map['ProfilePicture'] ?? '',
      fcmToken: map['fcmToken'],
      createdAt: timestamp,
      createdAtRaw: rawCreatedAt,
    );
  }

  String get fullName => "$firstName $lastName".trim();
  String get fullRegisteredDate {
    if (createdAt == null) return 'Chưa có';

    final date = createdAt!.toDate();
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year} at "
        "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }
}
