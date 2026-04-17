import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kc_admin_panel/Admin/models/order/order_model.dart';

class OrderRepository {
  final _db = FirebaseFirestore.instance;

  /// Lấy đơn hàng theo userId
  Stream<List<OrderModel>> getOrdersByUser(String userId) {
    return _db.collection('Users').doc(userId).collection('Orders').snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => OrderModel.fromMap(doc.data(), doc.id)).toList());
  }

  /// Lấy tất cả đơn hàng trong hệ thống
  Stream<List<OrderModel>> getAllOrders() {
    return _db.collectionGroup('Orders').snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => OrderModel.fromMap(doc.data(), doc.id)).toList());
  }

  /// Cập nhật trạng thái đơn hàng
  Future<void> updateOrderStatus(String userId, String orderId, String newStatus) async {
    await _db.collection('Users').doc(userId).collection('Orders').doc(orderId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Xoá đơn hàng
  Future<void> deleteOrder(String userId, String orderId) async {
    await _db.collection('Users').doc(userId).collection('Orders').doc(orderId).delete();
  }

  /// Lấy thông tin user (name, email, phone, avatar)
  Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    final doc = await _db.collection('Users').doc(userId).get();
    return doc.data();
  }
}
