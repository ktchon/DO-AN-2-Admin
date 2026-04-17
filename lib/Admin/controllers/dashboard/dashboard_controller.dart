import 'package:flutter/material.dart';

class DashboardController with ChangeNotifier {
  final Map<String, dynamic> stats = {
    'salesTotal': 30117.28,
    'avgOrder': 654.72,
    'totalOrders': 46,
    'visitors': 39,
  };

  final List<double> weeklySales = [120, 450, 2100, 800, 3900];

  final List<Map<String, dynamic>> orderStatus = [
    {'status': 'Shipped', 'count': 26, 'color': Colors.blue},
    {'status': 'Pending', 'count': 10, 'color': Colors.green},
    {'status': 'Cancelled', 'count': 5, 'color': Colors.purple},
    {'status': 'Processing', 'count': 5, 'color': Colors.orange},
  ];

  // Demo recent orders
  final List<Map<String, dynamic>> recentOrders = [
    {'id': '#c5b94', 'status': 'Shipped', 'statusColor': Colors.purple[100], 'amount': '\$336'},
    {'id': '#695c9', 'status': 'Delivered', 'statusColor': Colors.green[100], 'amount': '\$515.4'},
    {'id': '#d8f82', 'status': 'Pending', 'statusColor': Colors.blue[100], 'amount': '\$420'},
  ];

  void refreshData() {
    // TODO: Sau này gọi Firestore
    notifyListeners();
  }
}
