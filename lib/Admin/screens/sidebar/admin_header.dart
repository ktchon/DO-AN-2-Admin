import 'package:flutter/material.dart';
import 'package:kc_admin_panel/Admin/models/notification/notification_model.dart';
import 'package:kc_admin_panel/Admin/models/profile/profile_model.dart';
import 'package:kc_admin_panel/data/profile/profile_service.dart';

class AdminHeader extends StatelessWidget {
  const AdminHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ProfileModel>(
      valueListenable: ProfileService().profileNotifier,
      builder: (context, profile, child) {
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

              // Notification với Dropdown

              ValueListenableBuilder<List<NotificationModel>>(
                valueListenable:
                    notificationController.recentNotificationsNotifier, // hoặc dùng StreamBuilder
                builder: (context, notifications, child) {
                  final unreadCount = notifications.where((n) => !n.isRead).length;

                  return PopupMenuButton(
                    icon: Stack(
                      children: [
                        const Icon(Icons.notifications_none, size: 28),
                        if (unreadCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                unreadCount.toString(),
                                style: const TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            ),
                          ),
                      ],
                    ),
                    itemBuilder: (context) => notifications.take(10).map((noti) {
                      return PopupMenuItem(
                        child: ListTile(
                          leading: Icon(
                            noti.type == 'order'
                                ? Icons.shopping_cart
                                : noti.type == 'report'
                                    ? Icons.report
                                    : Icons.person,
                            color: Colors.blue,
                          ),
                          title: Text(noti.title),
                          subtitle: Text(noti.timeAgo),
                          trailing: noti.isRead
                              ? null
                              : const Icon(Icons.circle, size: 10, color: Colors.red),
                          onTap: () {
                            // Xử lý click vào thông báo
                            controller.markAsRead(noti.id);
                            _handleNotificationTap(noti);
                          },
                        ),
                      );
                    }).toList()
                      ..add(
                        const PopupMenuItem(
                          child: Text("Xem tất cả thông báo", style: TextStyle(color: Colors.blue)),
                        ),
                      ),
                  );
                },
              ),

              const SizedBox(width: 30),

              // User Info
              CircleAvatar(
                radius: 18,
                backgroundImage: profile.profileImageUrl.isNotEmpty
                    ? NetworkImage(profile.profileImageUrl)
                    : null,
                backgroundColor: const Color.fromARGB(255, 199, 200, 201),
                child: profile.profileImageUrl.isEmpty
                    ? const Text(
                        '?',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      )
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
      },
    );
  }
}
