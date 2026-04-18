import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kc_admin_panel/Admin/models/notification/notification_model.dart';

class NotificationRepository {
  final _db = FirebaseFirestore.instance;

  // Lấy 10 thông báo mới nhất
  Stream<List<NotificationModel>> getRecentNotifications() {
    return _db.collection('Notifications')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Đánh dấu đã đọc
  Future<void> markAsRead(String notificationId) async {
    await _db.collection('Notifications').doc(notificationId).update({'isRead': true});
  }

  // Tạo thông báo mới (gọi từ các nơi khác)
  Future<void> createNotification({
    required String type,
    required String subtype,
    required String title,
    required String body,
    required Map<String, dynamic> data,
    String? userId,
  }) async {
    await _db.collection('Notifications').add({
      'type': type,
      'subtype': subtype,
      'title': title,
      'body': body,
      'data': data,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
      'userId': userId,
    });
  }
}