import 'package:flutter/material.dart';
import 'package:kc_admin_panel/Admin/screens/sidebar/admin_sidebar_menu.dart';

class AdminSidebar extends StatelessWidget {
  final String currentRoute;

  const AdminSidebar({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    'Bảng Quản Trị',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),

          // MENU
          const Padding(
            padding: EdgeInsets.only(left: 24, bottom: 8),
            child: Text('MENU',
                style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w800)),
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
              style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w800),
            ),
          ),

          AdminSidebarMenu(icon: Icons.person_outline, title: 'Hồ sơ'),
          AdminSidebarMenu(icon: Icons.settings_outlined, title: 'Cài đặt'),
          AdminSidebarMenu(
            icon: Icons.logout_outlined,
            title: 'Đăng xuất',
            onTap: () => Navigator.pushReplacementNamed(context, '/admin/login'),
          ),
        ],
      ),
    );
  }
}
