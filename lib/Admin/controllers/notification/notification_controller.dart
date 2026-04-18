import 'package:kc_admin_panel/data/notification/notification_repository.dart';
import '../../models/notification/notification_model.dart';


class NotificationController {
  final repo = NotificationRepository();

  Stream<List<NotificationModel>> getRecentNotifications() => repo.getRecentNotifications();

  Future<void> markAsRead(String notificationId) => repo.markAsRead(notificationId);

  // Helper methods
  Future<void> createOrderPlacedNotification(String orderId, String userName) =>
      repo.createNotification(
        type: 'order',
        subtype: 'placed',
        title: 'Đơn hàng mới',
        body: 'Đơn hàng #$orderId đã được đặt thành công',
        data: {'orderId': orderId},
      );

  Future<void> createNewUserNotification(String userId, String userName) =>
      repo.createNotification(
        type: 'user',
        subtype: 'new_user',
        title: 'Khách hàng mới',
        body: '$userName vừa đăng ký tài khoản',
        data: {'userId': userId},
      );

  Future<void> createReportNotification(String reviewId, String reason) =>
      repo.createNotification(
        type: 'report',
        subtype: 'new_report',
        title: 'Báo cáo mới',
        body: 'Có báo cáo: $reason',
        data: {'reviewId': reviewId},
      );
}