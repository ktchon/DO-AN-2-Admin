import 'package:flutter/material.dart';
import 'package:kc_admin_panel/Admin/controllers/notification/notification_controller.dart';
import 'package:kc_admin_panel/Admin/models/notification/notification_model.dart';
import 'package:kc_admin_panel/Admin/screens/admin_sidebar.dart';
import 'package:kc_admin_panel/Admin/screens/sidebar/admin_header.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final controller = NotificationController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          const AdminSidebar(currentRoute: '/admin/notifications'),
          Expanded(
            child: Column(
              children: [
                const AdminHeader(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Thông báo',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        Expanded(
                          child: StreamBuilder<List<NotificationModel>>(
                            stream: controller.getRecentNotifications(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Center(child: Text("Không có thông báo nào"));
                              }

                              final notifications = snapshot.data!;

                              return ListView.builder(
                                itemCount: notifications.length,
                                itemBuilder: (context, index) {
                                  final noti = notifications[index];
                                  return Card(
                                    color: Colors.white,
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: ListTile(
                                      leading: Icon(
                                        noti.type == 'order'
                                            ? Icons.shopping_cart
                                            : noti.type == 'report'
                                                ? Icons.report_problem
                                                : Icons.person,
                                        color: Colors.blue,
                                      ),
                                      title: Text(noti.title),
                                      subtitle: Text(noti.body),
                                      trailing: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(noti.timeAgo, style: const TextStyle(fontSize: 12)),
                                          if (!noti.isRead)
                                            const Icon(Icons.circle, size: 10, color: Colors.red),
                                        ],
                                      ),
                                      onTap: () {
                                        controller.markAsRead(noti.id);
                                        // Chuyển đến trang tương ứng
                                        if (noti.type == 'order' && noti.data['orderId'] != null) {
                                          // Navigator.push(... OrderDetailScreen);
                                        } else if (noti.type == 'report' &&
                                            noti.data['reviewId'] != null) {
                                          // Navigator.push(... ReportDetailScreen);
                                        } else if (noti.type == 'user' &&
                                            noti.data['userId'] != null) {
                                          // Navigator.push(... CustomerDetailScreen);
                                        }
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
