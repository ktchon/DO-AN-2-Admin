import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kc_admin_panel/Admin/models/products/product_model.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy TẤT CẢ sản phẩm 
  Stream<List<ProductModel>> getProductsStream() {
    return _firestore.collection('Products').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)).toList());
  }

  // Tạo sản phẩm với ID thủ công + thêm createdAt để sau này dễ quản lý
  Future<void> createProduct(ProductModel product) async {
    try {
      await _firestore.collection('Products').doc(product.id).set({
        ...product.toMap(),
        'createdAt': FieldValue.serverTimestamp(), // Thêm field này
      });

      print("✅ Product created successfully with ID: ${product.id}");
    } catch (e) {
      print("❌ Error creating product: $e");
      rethrow;
    }
  }

  // Các hàm còn lại giữ nguyên
  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    await _firestore.collection('Products').doc(productId).update(data);
  }

  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('Products').doc(productId).delete();
  }

  Future<void> toggleFeatured(String productId, bool isFeatured) async {
    await _firestore.collection('Products').doc(productId).update({
      'isFeatured': isFeatured,
    });
  }
}
