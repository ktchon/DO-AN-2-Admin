import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kc_admin_panel/Admin/models/user/address_model.dart';
import 'package:kc_admin_panel/Admin/models/user/user_model.dart';

class UserRepository {
  final _db = FirebaseFirestore.instance;

  /// Lấy tất cả Users + sắp xếp client-side (an toàn nhất)
  Stream<List<UserModel>> getUsers() {
    return _db.collection('Users').snapshots().map((snapshot) {
      // In ra console để debug (bạn mở console xem có bao nhiêu document)
      print("📊 Firestore Users snapshot received: ${snapshot.docs.length} documents");

      final list = snapshot.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList();

      // Sắp xếp: user mới nhất (có createdAt) lên đầu
      list.sort((a, b) {
        final timeA = a.createdAt?.millisecondsSinceEpoch ?? 0;
        final timeB = b.createdAt?.millisecondsSinceEpoch ?? 0;
        return timeB.compareTo(timeA);
      });

      return list;
    });
  }

  // Lấy chi tiết một User
  Future<UserModel> getUserById(String userId) async {
    try {
      final doc = await _db.collection('Users').doc(userId).get();
      if (!doc.exists) {
        throw Exception("User không tồn tại");
      }
      return UserModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      print("❌ Error getUserById: $e");
      rethrow;
    }
  }

  // Lấy danh sách Addresses của user
  Stream<List<AddressModel>> getUserAddresses(String userId) {
    return _db.collection('Users').doc(userId).collection('Addresses').snapshots().map((snapshot) {
      print("📍 Addresses for user $userId: ${snapshot.docs.length} addresses");
      return snapshot.docs.map((doc) => AddressModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // ==================== HÀM XÓA USER (ĐÃ THÊM) ====================

  /// Xóa toàn bộ user (User document + tất cả subcollections: Addresses, Orders, SearchHistory...)
  Future<void> deleteUser(String userId) async {
    final batch = _db.batch();
    final userRef = _db.collection('Users').doc(userId);

    try {
      // 1. Xóa tất cả Addresses
      final addressesSnapshot = await userRef.collection('Addresses').get();
      for (var doc in addressesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // 2. Xóa tất cả Orders (nếu có subcollection Orders)
      final ordersSnapshot = await userRef.collection('Orders').get();
      for (var doc in ordersSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // 3. Xóa tất cả SearchHistory (nếu có)
      final searchHistorySnapshot = await userRef.collection('SearchHistory').get();
      for (var doc in searchHistorySnapshot.docs) {
        batch.delete(doc.reference);
      }

      // 4. Xóa document User chính
      batch.delete(userRef);

      await batch.commit();

      print("✅ Đã xóa user $userId thành công (bao gồm subcollections)");
    } catch (e) {
      print("❌ Lỗi khi xóa user $userId: $e");
      rethrow;
    }
  }

  // Nếu chỉ muốn xóa user document (không xóa subcollections)
  Future<void> deleteUserOnly(String userId) async {
    await _db.collection('Users').doc(userId).delete();
  }
}
