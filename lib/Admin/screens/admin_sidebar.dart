import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kc_admin_panel/Admin/models/setting/setting_model.dart';
import 'package:kc_admin_panel/Admin/screens/sidebar/admin_sidebar_menu.dart';
import 'package:kc_admin_panel/data/setting/app_settings_service.dart';

class AdminSidebar extends StatelessWidget {
  final String currentRoute;

  const AdminSidebar({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppSettingsModel>(
        valueListenable: AppSettingsService().settingsNotifier,
        builder: (context, settings, child) {
          return Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 2),
            child: Container(
              width: 260,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24), 
                border: Border.all(
                  color: Colors.green, 
                  width: 5.0, 
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // App Logo + Name
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Icon App
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: settings.appIconUrl.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(settings.appIconUrl),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            color: settings.appIconUrl.isEmpty ? Colors.grey[100] : null,
                          ),
                          child: settings.appIconUrl.isEmpty
                              ? const Icon(Icons.image, size: 40, color: Colors.grey)
                              : null,
                        ),
                        const SizedBox(height: 12),
            
                        // App Name
                        Text(
                          settings.appName,
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Divider(
                    height: 20,
                    color: Colors.green,
                    thickness: 2,
                  ),
                  const SizedBox(height: 10),
                  // MENU
                  const Padding(
                    padding: EdgeInsets.only(left: 24, bottom: 8),
                    child: Text('MENU',
                        style: TextStyle(
                            fontSize: 16, color: Colors.black, fontWeight: FontWeight.w800)),
                  ),
            
                  AdminSidebarMenu(
                    icon: Icons.dashboard_outlined,
                    title: 'Bảng quản trị',
                    isSelected: currentRoute == '/admin/dashboard',
                    onTap: () => Navigator.pushReplacementNamed(context, '/admin/dashboard'),
                  ),
                  AdminSidebarMenu(
                    icon: Iconsax.receipt_text,
                    title: 'Đơn hàng',
                    isSelected: currentRoute == '/admin/orders',
                    onTap: () => Navigator.pushReplacementNamed(context, '/admin/orders'),
                  ),
                  AdminSidebarMenu(
                    icon: Icons.people_outline,
                    title: 'Khách hàng',
                    isSelected: currentRoute == '/admin/customers',
                    onTap: () => Navigator.pushReplacementNamed(context, '/admin/customers'),
                  ),
                  AdminSidebarMenu(
                    icon: Iconsax.message,
                    title: 'Đánh giá',
                    isSelected: currentRoute == '/admin/reports',
                    onTap: () => Navigator.pushReplacementNamed(context, '/admin/reports'),
                  ),
                  AdminSidebarMenu(
                    icon: Icons.inventory_2_outlined,
                    title: 'Sản phẩm',
                    isSelected: currentRoute == '/admin/products',
                    onTap: () => Navigator.pushReplacementNamed(context, '/admin/products'),
                  ),
                  AdminSidebarMenu(
                    icon: Icons.category_outlined,
                    title: 'Danh mục',
                    isSelected: currentRoute == '/admin/categories',
                    onTap: () => Navigator.pushReplacementNamed(context, '/admin/categories'),
                  ),
                  AdminSidebarMenu(
                    icon: Icons.branding_watermark_outlined,
                    title: 'Thương hiệu',
                    isSelected: currentRoute == '/admin/brands',
                    onTap: () => Navigator.pushReplacementNamed(context, '/admin/brands'),
                  ),
                  AdminSidebarMenu(
                    icon: Icons.view_carousel_outlined,
                    title: 'Banners',
                    isSelected: currentRoute == '/admin/banners',
                    onTap: () => Navigator.pushReplacementNamed(context, '/admin/banners'),
                  ),
                  AdminSidebarMenu(
                    icon: Icons.local_offer_outlined,
                    title: 'Mã khuyến mãi',
                    isSelected: currentRoute == '/admin/coupons',
                    onTap: () => Navigator.pushReplacementNamed(context, '/admin/coupons'),
                  ),
                  AdminSidebarMenu(
                    icon: Icons.image_outlined,
                    title: 'Hình ảnh',
                    isSelected: currentRoute == '/admin/media',
                    onTap: () => Navigator.pushReplacementNamed(context, '/admin/media'),
                  ),
                  AdminSidebarMenu(
                    icon: Icons.notifications_none_outlined,
                    title: 'Thông báo',
                    isSelected: currentRoute == '/admin/notifications',
                    onTap: () => Navigator.pushReplacementNamed(context, '/admin/notifications'),
                  ),
            
                  const Divider(
                    height: 10,
                    color: Colors.green,
                    thickness: 2,
                  ),
                  const Spacer(),
            
                  // OTHER
                  const Padding(
                    padding: EdgeInsets.only(left: 24, bottom: 8),
                    child: Text(
                      'KHÁC',
                      style:
                          TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w800),
                    ),
                  ),
            
                  AdminSidebarMenu(
                    icon: Icons.person_outline,
                    title: 'Hồ sơ',
                    isSelected: currentRoute == '/admin/profile',
                    onTap: () => Navigator.pushReplacementNamed(context, '/admin/profile'),
                  ),
                  AdminSidebarMenu(
                    icon: Icons.settings_outlined,
                    title: 'Cài đặt',
                    isSelected: currentRoute == '/admin/settings',
                    onTap: () => Navigator.pushReplacementNamed(context, '/admin/settings'),
                  ),
                  AdminSidebarMenu(
                    icon: Icons.logout_outlined,
                    title: 'Đăng xuất',
                    onTap: () => Navigator.pushReplacementNamed(context, '/admin/login'),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
