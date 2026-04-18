import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String type;           // "order", "user", "report"
  final String subtype;        // "placed", "cancelled", ...
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final bool isRead;
  final Timestamp createdAt;
  final String? userId;

  NotificationModel({
    required this.id,
    required this.type,
    required this.subtype,
    required this.title,
    required this.body,
    required this.data,
    required this.isRead,
    required this.createdAt,
    this.userId,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      type: map['type'] ?? 'order',
      subtype: map['subtype'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      data: map['data'] as Map<String, dynamic>? ?? {},
      isRead: map['isRead'] ?? false,
      createdAt: map['createdAt'] ?? Timestamp.now(),
      userId: map['userId'],
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt.toDate());
    if (diff.inDays > 0) return "${diff.inDays} ngày trước";
    if (diff.inHours > 0) return "${diff.inHours} giờ trước";
    if (diff.inMinutes > 0) return "${diff.inMinutes} phút trước";
    return "Vừa xong";
  }
}