import 'package:flutter/material.dart';
import 'package:kc_admin_panel/Admin/screens/banner/banners_screen.dart';
import 'package:kc_admin_panel/Admin/screens/brand/brands_screen.dart';
import 'package:kc_admin_panel/Admin/screens/category/categories_screen.dart';
import 'package:kc_admin_panel/Admin/screens/coupon/coupons_screen.dart';
import 'package:kc_admin_panel/Admin/screens/dashboard/admin_dashboard_screen.dart'
    show AdminDashboardScreen;
import 'package:kc_admin_panel/Admin/screens/login/login_screen.dart';
import 'package:kc_admin_panel/Admin/screens/media/media_screen.dart';
import 'package:kc_admin_panel/Admin/screens/products/products_screen.dart';
import 'package:kc_admin_panel/Admin/screens/user/customer_screen.dart';
import 'package:kc_admin_panel/routes/routes.dart';

class MyAdminApp extends StatelessWidget {
  const MyAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bảng Quản Trị',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.adminLogin,
      routes: {
        AppRoutes.adminLogin: (context) => const AdminLoginScreen(),
        AppRoutes.adminDashboard: (context) => const AdminDashboardScreen(),
        AppRoutes.categories: (context) => const CategoriesScreen(),
        AppRoutes.media: (context) => const MediaScreen(),
        AppRoutes.banner: (context) => const BannersScreen(),
        AppRoutes.product: (context) => const ProductsScreen(),
        AppRoutes.brand: (context) => const BrandsScreen(),
        AppRoutes.coupon: (context) => const CouponsScreen(),
        AppRoutes.customer: (context) => const CustomersScreen(),
      },
    );
  }
}
