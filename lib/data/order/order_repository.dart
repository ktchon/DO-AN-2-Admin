import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kc_admin_panel/Admin/models/order/order_model.dart';

class OrderRepository {
  final _db = FirebaseFirestore.instance;

  // Lấy tất cả Orders của một User (dùng cho Customer Detail)
  Stream<List<OrderModel>> getOrdersByUser(String userId) {
    return _db
        .collection('Users')
        .doc(userId)
        .collection('Orders')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Lấy tất cả Orders trong hệ thống (dùng cho trang Orders sau này)
  Stream<List<OrderModel>> getAllOrders() {
    // Nếu bạn có collection Orders riêng ở root, dùng cái này
    // Hiện tại theo cấu trúc của bạn là subcollection trong User
    // Nếu sau này tách riêng, ta sẽ điều chỉnh
    return _db.collectionGroup('Orders').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Cập nhật trạng thái đơn hàng (tương lai)
  Future<void> updateOrderStatus(String userId, String orderId, String newStatus) async {
    await _db
        .collection('Users')
        .doc(userId)
        .collection('Orders')
        .doc(orderId)
        .update({'status': newStatus, 'updatedAt': FieldValue.serverTimestamp()});
  }
}