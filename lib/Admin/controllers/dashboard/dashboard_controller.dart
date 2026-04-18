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
  List<OrderModel> _monthlyOrders = [];
  List<OrderModel> _yearlyOrders = [];
  List<UserModel> _users = [];

  StreamSubscription<List<OrderModel>>? _allOrdersSub;
  StreamSubscription<List<OrderModel>>? _recentOrdersSub;
  StreamSubscription<List<OrderModel>>? _weeklyOrdersSub;
  StreamSubscription<List<OrderModel>>? _monthlyOrdersSub;
  StreamSubscription<List<OrderModel>>? _yearlyOrdersSub;
  StreamSubscription<List<UserModel>>? _usersSub;

  int _pendingStreams = 0;

  // ─── Constructor ───────────────────────────────────────────────────────────
  DashboardController() {
    _subscribeToAllStreams();
  }

  void _subscribeToAllStreams() {
    isLoading = true;
    error = null;
    _pendingStreams = 6; // allOrders, recent, weekly, monthly, yearly, users

    notifyListeners();

    // All Orders (quan trọng nhất)
    _allOrdersSub = _repo.watchAllOrders().listen(
      (orders) {
        _allOrders = orders;
        _onStreamDataReceived();
      },
      onError: (e) => _onStreamError(e),
    );

    // Recent Orders
    _recentOrdersSub = _repo.watchRecentOrders(limit: 10).listen(
      (orders) {
        _recentOrders = orders;
        _onStreamDataReceived();
      },
      onError: (e) => _onStreamError(e),
    );

    // Weekly Orders
    _weeklyOrdersSub = _repo.watchWeeklyOrders().listen(
      (orders) {
        _weeklyOrders = orders;
        _onStreamDataReceived();
      },
      onError: (e) => _onStreamError(e),
    );

    // Monthly Orders
    _monthlyOrdersSub = _repo.watchMonthlyOrders().listen(
      (orders) {
        _monthlyOrders = orders;
        _onStreamDataReceived();
      },
      onError: (e) => _onStreamError(e),
    );

    // Yearly Orders
    _yearlyOrdersSub = _repo.watchYearlyOrders().listen(
      (orders) {
        _yearlyOrders = orders;
        _onStreamDataReceived();
      },
      onError: (e) => _onStreamError(e),
    );

    // Users
    _usersSub = _repo.watchAllUsers().listen(
      (users) {
        _users = users;
        _onStreamDataReceived();
      },
      onError: (e) => _onStreamError(e),
    );
  }

  void _onStreamDataReceived() {
    _pendingStreams = (_pendingStreams - 1).clamp(0, 999);
    if (_pendingStreams <= 0) {
      isLoading = false;
    }
    notifyListeners();
  }

  void _onStreamError(dynamic e) {
    error = e.toString();
    _pendingStreams = (_pendingStreams - 1).clamp(0, 999);
    if (_pendingStreams <= 0) {
      isLoading = false;
    }
    notifyListeners();
  }

  // Hàm refresh thủ công (gọi khi cần tải lại dữ liệu)
  void refresh() {
    // Hủy tất cả subscription cũ
    _disposeSubscriptions();

    // Xóa dữ liệu cũ
    _allOrders.clear();
    _recentOrders.clear();
    _weeklyOrders.clear();
    _monthlyOrders.clear();
    _yearlyOrders.clear();
    _users.clear();

    isLoading = true;
    error = null;
    notifyListeners();

    // Subscribe lại
    _subscribeToAllStreams();
  }

  void _disposeSubscriptions() {
    _allOrdersSub?.cancel();
    _recentOrdersSub?.cancel();
    _weeklyOrdersSub?.cancel();
    _monthlyOrdersSub?.cancel();
    _yearlyOrdersSub?.cancel();
    _usersSub?.cancel();

    _allOrdersSub = null;
    _recentOrdersSub = null;
    _weeklyOrdersSub = null;
    _monthlyOrdersSub = null;
    _yearlyOrdersSub = null;
    _usersSub = null;
  }

  // ─── Computed Getters ──────────────────────────────────────────────────────
  double get salesTotal => _allOrders.fold(0.0, (sum, o) => sum + (o.totalAmount ?? 0));

  double get avgOrderValue => _allOrders.isEmpty ? 0 : salesTotal / _allOrders.length;

  int get totalOrders => _allOrders.length;
  int get totalUsers => _users.length;

  List<OrderModel> get recentOrdersList => _recentOrders;

  // Weekly Sales Data
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

  // Monthly Sales Data (6 tháng)
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

  // Yearly Sales Data (4 năm)
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

  // Order Status
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

  // ─── Dispose ───────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _disposeSubscriptions();
    super.dispose();
  }
}
