import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kc_admin_panel/Admin/models/order/order_model_dashboard.dart';
import 'package:kc_admin_panel/Admin/models/user/user_model_dashboard.dart';
import 'package:kc_admin_panel/data/dashboard/dashboard_repository.dart';

class DashboardController with ChangeNotifier {
  final DashboardRepository _repo = DashboardRepository();

  // ─── State ─────────────────────────────────────────────────────────────────
  bool isLoading = true;
  String? error;

  List<OrderModel> _allOrders = [];
  List<OrderModel> _recentOrders = [];
  List<OrderModel> _weeklyOrders = [];
  List<UserModel> _users = [];

  StreamSubscription<List<OrderModel>>? _allOrdersSub;
  StreamSubscription<List<OrderModel>>? _recentOrdersSub;
  StreamSubscription<List<OrderModel>>? _weeklyOrdersSub;
  StreamSubscription<List<UserModel>>? _usersSub;

  // ─── Init ──────────────────────────────────────────────────────────────────
  DashboardController() {
    _subscribeAll();
  }

  void _subscribeAll() {
    isLoading = true;
    error = null;

    // All orders
    _allOrdersSub = _repo.watchAllOrders().listen(
      (orders) {
        _allOrders = orders;
        isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        error = e.toString();
        isLoading = false;
        notifyListeners();
      },
    );

    // Recent 10 orders
    _recentOrdersSub = _repo.watchRecentOrders(limit: 10).listen(
      (orders) {
        _recentOrders = orders;
        notifyListeners();
      },
    );

    // Weekly orders
    _weeklyOrdersSub = _repo.watchWeeklyOrders().listen(
      (orders) {
        _weeklyOrders = orders;
        notifyListeners();
      },
    );

    // Users
    _usersSub = _repo.watchAllUsers().listen(
      (users) {
        _users = users;
        notifyListeners();
      },
    );
  }

  // ─── Computed Metrics ──────────────────────────────────────────────────────

  /// Tổng doanh thu
  double get salesTotal =>
      _allOrders.fold(0.0, (sum, o) => sum + o.totalAmount);

  /// Giá trị đơn trung bình
  double get avgOrderValue =>
      _allOrders.isEmpty ? 0 : salesTotal / _allOrders.length;

  /// Tổng số đơn
  int get totalOrders => _allOrders.length;

  /// Tổng số users (= "visitors")
  int get totalUsers => _users.length;

  /// Đơn theo status
  Map<String, int> get orderStatusCounts {
    final map = <String, int>{};
    for (final o in _allOrders) {
      map[o.status] = (map[o.status] ?? 0) + 1;
    }
    return map;
  }

  /// Tổng tiền theo status
  Map<String, double> get orderStatusTotals {
    final map = <String, double>{};
    for (final o in _allOrders) {
      map[o.status] = (map[o.status] ?? 0.0) + o.totalAmount;
    }
    return map;
  }

  /// Dữ liệu bar chart: doanh thu theo từng ngày trong 7 ngày gần nhất
  /// Trả về List<double> index 0 = 6 ngày trước, index 6 = hôm nay
  List<double> get weeklySalesData {
    final now = DateTime.now();
    final result = List<double>.filled(7, 0.0);
    for (final order in _weeklyOrders) {
      final diff = now.difference(order.createdAt).inDays;
      if (diff >= 0 && diff < 7) {
        result[6 - diff] += order.totalAmount;
      }
    }
    return result;
  }

  /// Nhãn 7 ngày (e.g. "Mon", "Tue"...) tương ứng với weeklySalesData
  List<String> get weekDayLabels {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final now = DateTime.now();
    return List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return days[d.weekday % 7];
    });
  }

  /// Danh sách status cần hiển thị với màu sắc
  List<Map<String, dynamic>> get orderStatusList => [
        {
          'status': 'pending',
          'label': 'Pending',
          'color': Colors.blue,
          'count': orderStatusCounts['pending'] ?? 0,
          'total': orderStatusTotals['pending'] ?? 0.0,
        },
        {
          'status': 'processing',
          'label': 'Processing',
          'color': Colors.orange,
          'count': orderStatusCounts['processing'] ?? 0,
          'total': orderStatusTotals['processing'] ?? 0.0,
        },
        {
          'status': 'shipped',
          'label': 'Shipped',
          'color': Colors.purple,
          'count': orderStatusCounts['shipped'] ?? 0,
          'total': orderStatusTotals['shipped'] ?? 0.0,
        },
        {
          'status': 'delivered',
          'label': 'Delivered',
          'color': Colors.green,
          'count': orderStatusCounts['delivered'] ?? 0,
          'total': orderStatusTotals['delivered'] ?? 0.0,
        },
        {
          'status': 'cancelled',
          'label': 'Cancelled',
          'color': Colors.red,
          'count': orderStatusCounts['cancelled'] ?? 0,
          'total': orderStatusTotals['cancelled'] ?? 0.0,
        },
      ];

  // ─── Recent orders (cho DataTable) ────────────────────────────────────────
  List<OrderModel> get recentOrdersList => _recentOrders;

  // ─── Dispose ───────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _allOrdersSub?.cancel();
    _recentOrdersSub?.cancel();
    _weeklyOrdersSub?.cancel();
    _usersSub?.cancel();
    super.dispose();
  }
}