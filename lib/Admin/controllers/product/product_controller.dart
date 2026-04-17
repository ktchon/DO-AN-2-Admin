import 'package:flutter/material.dart';
import 'package:kc_admin_panel/Admin/models/products/product_model.dart';
import 'package:kc_admin_panel/data/product/product_repository.dart';

class ProductController with ChangeNotifier {
  final ProductRepository _repository = ProductRepository();

  // Stream lấy danh sách sản phẩm
  Stream<List<ProductModel>> getProducts() {
    return _repository.getProductsStream();
  }

  // Tạo sản phẩm mới
  Future<void> createProduct(ProductModel product) async {
    try {
      await _repository.createProduct(product);

      // Buộc giao diện refresh ngay lập tức
      notifyListeners();

      print("✅ Product created successfully: ${product.id}");
    } catch (e) {
      print("❌ Create product error: $e");
      rethrow;
    }
  }

  // Cập nhật sản phẩm
  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    try {
      await _repository.updateProduct(productId, data);
      notifyListeners();
    } catch (e) {
      print("❌ Update product error: $e");
      rethrow;
    }
  }

  // Xóa sản phẩm
  Future<void> deleteProduct(String productId) async {
    try {
      await _repository.deleteProduct(productId);
      notifyListeners();
    } catch (e) {
      print("❌ Delete product error: $e");
      rethrow;
    }
  }

  // Toggle Featured
  Future<void> toggleFeatured(String productId, bool isFeatured) async {
    try {
      await _repository.toggleFeatured(productId, isFeatured);
      notifyListeners();
    } catch (e) {
      print("❌ Toggle featured error: $e");
      rethrow;
    }
  }
}
