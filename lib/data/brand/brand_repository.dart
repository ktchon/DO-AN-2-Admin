import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kc_admin_panel/Admin/models/brand/brand_model.dart';

class BrandRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<BrandModel>> getBrands() {
    return _db.collection('Brands').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return BrandModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> updateBrand(BrandModel brand) async {
    await _db.collection('Brands').doc(brand.id).update({
      'Name': brand.name,
      'Image': brand.image,
      'IsFeatured': brand.isFeatured,
      'ProductsCount': brand.productsCount,
      'UpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteBrand(String id) async {
    await _db.collection('Brands').doc(id).delete();
  }

  Future<void> createBrand(BrandModel brand) async {
    final doc = _db.collection('Brands').doc(brand.id);

    final existing = await doc.get();

    if (existing.exists) {
      throw Exception("ID đã tồn tại");
    }

    await doc.set({
      'Id': brand.id,
      'Name': brand.name,
      'Image': brand.image,
      'IsFeatured': brand.isFeatured,
      'ProductsCount': brand.productsCount,
      'CreatedAt': FieldValue.serverTimestamp(),
    });
  }
}
