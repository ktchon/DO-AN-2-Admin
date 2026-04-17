import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kc_admin_panel/Admin/models/category/category_model.dart';

class CategoryRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<CategoryModel>> getCategories() {
    return _db.collection('Categories').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _db.collection('Categories').doc(category.id).update({
      'Name': category.name,
      'Image': category.image,
      'IsFeatured': category.isFeatured,
      'ParentId': category.parentId,
      'UpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteCategory(String id) async {
    await _db.collection('Categories').doc(id).delete();
  }

  Future<void> createCategory(CategoryModel category) async {
    final doc = _db.collection('Categories').doc(category.id);

    final existing = await doc.get();

    if (existing.exists) {
      throw Exception("ID đã tồn tại");
    }

    await doc.set({
      'Id': category.id,
      'Name': category.name,
      'Image': category.image,
      'IsFeatured': category.isFeatured,
      'ParentId': category.parentId,
      'CreatedAt': FieldValue.serverTimestamp(),
    });
  }
}
