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
  List<OrderModel> _weeklyOrders = []; // dùng cho tuần
  List<OrderModel> _monthlyOrders = []; // dùng cho tháng
  List<OrderModel> _yearlyOrders = []; // dùng cho năm

  List<UserModel> _users = [];

  StreamSubscription<List<OrderModel>>? _allOrdersSub;
  StreamSubscription<List<OrderModel>>? _recentOrdersSub;
  StreamSubscription<List<OrderModel>>? _weeklyOrdersSub;
  StreamSubscription<List<OrderModel>>? _monthlyOrdersSub;
  StreamSubscription<List<OrderModel>>? _yearlyOrdersSub;
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

    // Weekly orders (7 ngày)
    _weeklyOrdersSub = _repo.watchWeeklyOrders().listen(
      (orders) {
        _weeklyOrders = orders;
        notifyListeners();
      },
    );

    // Monthly orders (6 tháng gần nhất) - bạn cần thêm vào Repository
    _monthlyOrdersSub = _repo.watchMonthlyOrders().listen(
      (orders) {
        _monthlyOrders = orders;
        notifyListeners();
      },
    );

    // Yearly orders (12 tháng gần nhất)
    _yearlyOrdersSub = _repo.watchYearlyOrders().listen(
      (orders) {
        _yearlyOrders = orders;
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

  double get salesTotal => _allOrders.fold(0.0, (sum, o) => sum + (o.totalAmount ?? 0));

  double get avgOrderValue => _allOrders.isEmpty ? 0 : salesTotal / _allOrders.length;

  int get totalOrders => _allOrders.length;
  int get totalUsers => _users.length;

  // ─── Weekly Sales Data (7 ngày) ────────────────────────────────────────────
  List<double> get weeklySalesData {
    final now = DateTime.now();
    final result = List<double>.filled(7, 0.0);

    for (final order in _weeklyOrders) {
      if (order.createdAt == null) continue;
      final diff = now.difference(order.createdAt!).inDays;
      if (diff >= 0 && diff < 7) {
        result[6 - diff] += order.totalAmount ?? 0;
      }
    }
    return result;
  }

  List<String> get weekDayLabels {
    const days = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    final now = DateTime.now();
    return List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return days[d.weekday % 7];
    });
  }

  // ─── Monthly Sales Data (6 tháng gần nhất) ────────────────────────────────
  List<double> get monthlySalesData {
    final now = DateTime.now();
    final result = List<double>.filled(6, 0.0);

    for (final order in _monthlyOrders) {
      if (order.createdAt == null) continue;
      final monthDiff =
          (now.year - order.createdAt!.year) * 12 + (now.month - order.createdAt!.month);
      if (monthDiff >= 0 && monthDiff < 6) {
        result[5 - monthDiff] += order.totalAmount ?? 0;
      }
    }
    return result;
  }

  List<String> get monthLabels {
    final now = DateTime.now();
    return List.generate(6, (i) {
      final d = DateTime(now.year, now.month - (5 - i));
      return 'T${d.month}';
    });
  }

  // ─── Yearly Sales Data (4 năm gần nhất) ───────────────────────────────────
  List<double> get yearlySalesData {
    final now = DateTime.now();
    final result = List<double>.filled(4, 0.0);

    for (final order in _yearlyOrders) {
      if (order.createdAt == null) continue;
      final yearDiff = now.year - order.createdAt!.year;
      if (yearDiff >= 0 && yearDiff < 4) {
        result[3 - yearDiff] += order.totalAmount ?? 0;
      }
    }
    return result;
  }

  List<String> get yearLabels {
    final now = DateTime.now();
    return List.generate(4, (i) => '${now.year - (3 - i)}');
  }

  // ─── Order Status List ─────────────────────────────────────────────────────
  List<Map<String, dynamic>> get orderStatusList => [
        {
          'status': 'pending',
          'label': 'Chờ xử lý',
          'color': Colors.blue,
          'count': orderStatusCounts['pending'] ?? 0,
          'total': orderStatusTotals['pending'] ?? 0.0
        },
        {
          'status': 'processing',
          'label': 'Đang xử lý',
          'color': Colors.orange,
          'count': orderStatusCounts['processing'] ?? 0,
          'total': orderStatusTotals['processing'] ?? 0.0
        },
        {
          'status': 'shipped',
          'label': 'Đã giao',
          'color': Colors.purple,
          'count': orderStatusCounts['shipped'] ?? 0,
          'total': orderStatusTotals['shipped'] ?? 0.0
        },
        {
          'status': 'delivered',
          'label': 'Hoàn thành',
          'color': Colors.green,
          'count': orderStatusCounts['delivered'] ?? 0,
          'total': orderStatusTotals['delivered'] ?? 0.0
        },
        {
          'status': 'cancelled',
          'label': 'Đã hủy',
          'color': Colors.red,
          'count': orderStatusCounts['cancelled'] ?? 0,
          'total': orderStatusTotals['cancelled'] ?? 0.0
        },
      ];

  Map<String, int> get orderStatusCounts {
    final map = <String, int>{};
    for (final o in _allOrders) {
      final status = o.status.toLowerCase();
      map[status] = (map[status] ?? 0) + 1;
    }
    return map;
  }

  Map<String, double> get orderStatusTotals {
    final map = <String, double>{};
    for (final o in _allOrders) {
      final status = o.status.toLowerCase();
      map[status] = (map[status] ?? 0.0) + (o.totalAmount ?? 0);
    }
    return map;
  }

  List<OrderModel> get recentOrdersList => _recentOrders;

  // ─── Dispose ───────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _allOrdersSub?.cancel();
    _recentOrdersSub?.cancel();
    _weeklyOrdersSub?.cancel();
    _monthlyOrdersSub?.cancel();
    _yearlyOrdersSub?.cancel();
    _usersSub?.cancel();
    super.dispose();
  }
}
