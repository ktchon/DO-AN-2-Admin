import 'package:kc_admin_panel/data/order/order_repository.dart';
import '../../models/order/order_model.dart';

class OrderController {
  final repo = OrderRepository();

  Stream<List<OrderModel>> getAllOrders() => repo.getAllOrders();

  Stream<List<OrderModel>> getOrdersByUser(String userId) =>
      repo.getOrdersByUser(userId);

  Future<void> updateOrderStatus(
          String userId, String orderId, String newStatus) =>
      repo.updateOrderStatus(userId, orderId, newStatus);

  Future<void> deleteOrder(String userId, String orderId) =>
      repo.deleteOrder(userId, orderId);

  Future<Map<String, dynamic>?> getUserInfo(String userId) =>
      repo.getUserInfo(userId);
}