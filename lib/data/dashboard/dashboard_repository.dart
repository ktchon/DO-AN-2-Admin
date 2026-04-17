import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kc_admin_panel/Admin/models/order/order_model_dashboard.dart';
import 'package:kc_admin_panel/Admin/models/user/user_model_dashboard.dart';

class DashboardRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── ALL ORDERS (realtime) ───────────────────────────────────────────────
  Stream<List<OrderModel>> watchAllOrders() {
    return _db
        .collectionGroup('Orders')
        .orderBy('orderDate', descending: true)   
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => OrderModel.fromDocument(doc))
            .toList());
  }

  // ─── ALL USERS (realtime) ────────────────────────────────────────────────
  Stream<List<UserModel>> watchAllUsers() {
    return _db
        .collection('Users')
        .orderBy(FieldPath.documentId, descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => UserModel.fromDocument(doc))
            .toList());
  }

  // ─── RECENT ORDERS (10 đơn mới nhất) ─────────────────────────────────────
  Stream<List<OrderModel>> watchRecentOrders({int limit = 10}) {
    return _db
        .collectionGroup('Orders')
        .orderBy('orderDate', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => OrderModel.fromDocument(doc))
            .toList());
  }

  // ─── WEEKLY ORDERS (7 ngày gần nhất) ─────────────────────────────────────
  Stream<List<OrderModel>> watchWeeklyOrders() {
    final fromDate = DateTime.now().subtract(const Duration(days: 7));
    final fromTimestamp = Timestamp.fromDate(fromDate);

    return _db
        .collectionGroup('Orders')
        .where('orderDate', isGreaterThanOrEqualTo: fromTimestamp)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => OrderModel.fromDocument(doc))
            .toList());
  }
}