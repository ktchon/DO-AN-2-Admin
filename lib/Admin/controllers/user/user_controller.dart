import 'package:kc_admin_panel/data/order/order_repository.dart';
import '../../../data/user/user_repository.dart';
import '../../models/user/user_model.dart';
import '../../models/user/address_model.dart';
import '../../models/order/order_model.dart'; 


class UserController {
  final repo = UserRepository();
  final orderRepo = OrderRepository(); // ← Khởi tạo OrderRepository

  Stream<List<UserModel>> getUsers() => repo.getUsers();

  Future<UserModel> getUserById(String userId) => repo.getUserById(userId);

  Stream<List<AddressModel>> getUserAddresses(String userId) => repo.getUserAddresses(userId);

  // ==================== THÊM HÀM LẤY ORDERS ====================

  /// Lấy tất cả đơn hàng của một user (dùng cho trang chi tiết khách hàng)
  Stream<List<OrderModel>> getOrdersByUser(String userId) => orderRepo.getOrdersByUser(userId);

  // ==================== HÀM XÓA ====================

  /// Xóa toàn bộ user (User + Addresses + Orders + SearchHistory)
  Future<void> deleteUser(String userId) async {
    await repo.deleteUser(userId);
  }

  /// Xóa chỉ User document (không xóa subcollections)
  Future<void> deleteUserOnly(String userId) async {
    await repo.deleteUserOnly(userId);
  }
}
