import 'package:flutter/material.dart';
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
        valueListenable: AppSettingsService().settingsNotifier, // ← Dùng notifier
        builder: (context, settings, child) {
          return Container(
            width: 260,
            color: Colors.white,
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
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

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
                  icon: Icons.image_outlined,
                  title: 'Hình ảnh',
                  isSelected: currentRoute == '/admin/media',
                  onTap: () => Navigator.pushReplacementNamed(context, '/admin/media'),
                ),
                AdminSidebarMenu(
                  icon: Icons.view_carousel_outlined,
                  title: 'Banners',
                  isSelected: currentRoute == '/admin/banners',
                  onTap: () => Navigator.pushReplacementNamed(context, '/admin/banners'),
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
                  icon: Icons.people_outline,
                  title: 'Khách hàng',
                  isSelected: currentRoute == '/admin/customers',
                  onTap: () => Navigator.pushReplacementNamed(context, '/admin/customers'),
                ),
                AdminSidebarMenu(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Đơn hàng',
                  isSelected: currentRoute == '/admin/orders',
                  onTap: () => Navigator.pushReplacementNamed(context, '/admin/orders'),
                ),
                AdminSidebarMenu(
                  icon: Icons.local_offer_outlined,
                  title: 'Mã khuyến mãi',
                  isSelected: currentRoute == '/admin/coupons',
                  onTap: () => Navigator.pushReplacementNamed(context, '/admin/coupons'),
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
                  isSelected: currentRoute == '/admin/settings',
                  onTap: () => Navigator.pushReplacementNamed(context, '/admin/settings'),
                ),
                AdminSidebarMenu(icon: Icons.settings_outlined, title: 'Cài đặt'),
                AdminSidebarMenu(
                  icon: Icons.logout_outlined,
                  title: 'Đăng xuất',
                  onTap: () => Navigator.pushReplacementNamed(context, '/admin/login'),
                ),
              ],
            ),
          );
        });
  }
}
