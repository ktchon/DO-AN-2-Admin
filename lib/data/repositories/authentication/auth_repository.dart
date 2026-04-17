import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> loginAdmin({
    required String email,
    required String password,
  }) async {
    try {
      // Đăng nhập Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;
      if (user == null) {
        return {'success': false, 'message': 'Không tìm thấy tài khoản'};
      }

      // Lấy thông tin user từ Firestore
      final DocumentSnapshot userDoc = await _firestore.collection('Users').doc(user.uid).get();

      if (!userDoc.exists) {
        await _auth.signOut();
        return {'success': false, 'message': 'Không tìm thấy thông tin người dùng'};
      }

      final Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

      // Kiểm tra Role == "admin"
      final String role = (data['Role'] ?? '').toString().toLowerCase();

      if (role != 'admin') {
        await _auth.signOut();
        return {'success': false, 'message': 'Bạn không có quyền truy cập Admin Panel'};
      }

      return {
        'success': true,
        'user': user,
        'userData': data,
        'message': 'Đăng nhập Admin thành công',
      };
    } on FirebaseAuthException catch (e) {
      String message = 'Đăng nhập thất bại';
      switch (e.code) {
        case 'user-not-found':
          message = 'Email không tồn tại';
          break;
        case 'wrong-password':
          message = 'Mật khẩu không đúng';
          break;
        case 'invalid-email':
          message = 'Email không hợp lệ';
          break;
        case 'user-disabled':
          message = 'Tài khoản đã bị khóa';
          break;
      }
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Lỗi: $e'};
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
