import 'package:flutter/material.dart';
import 'package:kc_admin_panel/Admin/controllers/notification/notification_controller.dart';
import 'package:kc_admin_panel/Admin/models/notification/notification_model.dart';
import 'package:kc_admin_panel/Admin/screens/notification/notifications_screen.dart';
import 'package:kc_admin_panel/Admin/screens/order/order_screen.dart';
import 'package:kc_admin_panel/Admin/screens/report/reports_screen.dart';
import 'package:kc_admin_panel/Admin/screens/user/customer_screen.dart';
import 'package:kc_admin_panel/data/profile/profile_service.dart';

class AdminHeader extends StatefulWidget {
  const AdminHeader({super.key});

  @override
  State<AdminHeader> createState() => _AdminHeaderState();
}

class _AdminHeaderState extends State<AdminHeader> {
  final notificationController = NotificationController();

  void _handleNotificationTap(NotificationModel noti) async {
    await notificationController.markAsRead(noti.id);

    if (!mounted) return;

    // Chuyển đến màn hình tương ứng theo loại thông báo
    if (noti.type == 'order') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OrdersScreen()),
      );
    } else if (noti.type == 'report') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ReportsScreen()),
      );
    } else if (noti.type == 'user') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CustomersScreen()),
      );
    }
  }

  void _goToAllNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ProfileService().profile;

    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          // Search bar
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search anything...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
              ),
            ),
          ),
          const SizedBox(width: 30),

          // ==================== NOTIFICATION DROPDOWN ====================
          StreamBuilder<List<NotificationModel>>(
            stream: notificationController.getRecentNotifications(),
            builder: (context, snapshot) {
              final notifications = snapshot.data ?? [];
              final unreadCount = notifications.where((n) => !n.isRead).length;

              return PopupMenuButton(
                tooltip: 'Xem thông báo',
                color: Colors.white,
                constraints: const BoxConstraints(
                  minWidth: 300, 
                ),
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications_none, size: 28),
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadCount > 9 ? '9+' : unreadCount.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ),
                  ],
                ),
                offset: const Offset(0, 50),
                itemBuilder: (context) {
                  if (notifications.isEmpty) {
                    return [
                      const PopupMenuItem(
                        enabled: false,
                        child: Text("Không có thông báo mới"),
                      ),
                    ];
                  }

                  final items = notifications.take(10).map((noti) {
                    return PopupMenuItem(
                      onTap: () => _handleNotificationTap(noti),
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
                        subtitle: Text(noti.timeAgo),
                        trailing: noti.isRead
                            ? null
                            : const Icon(Icons.circle, size: 10, color: Colors.red),
                        dense: true,
                      ),
                    );
                  }).toList();

                  // Nút "Xem tất cả thông báo"
                  items.add(
                    PopupMenuItem(
                      onTap: _goToAllNotifications,
                      child: const ListTile(
                        title: Text(
                          "Xem tất cả thông báo",
                          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  );

                  return items;
                },
              );
            },
          ),

          const SizedBox(width: 30),

          // User Info
          CircleAvatar(
            radius: 18,
            backgroundImage:
                profile.profileImageUrl.isNotEmpty ? NetworkImage(profile.profileImageUrl) : null,
            backgroundColor: const Color(0xFF1E88E5),
            child: profile.profileImageUrl.isEmpty
                ? const Text('A',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                : null,
          ),
          const SizedBox(width: 12),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.fullName.isNotEmpty ? profile.fullName : "App Admin",
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              Text(
                profile.email.isNotEmpty ? profile.email : "support@shopapp.com",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
