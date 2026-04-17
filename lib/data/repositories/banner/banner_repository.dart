import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kc_admin_panel/Admin/models/banner/banner_models.dart';

class BannerRepository {
  final _db = FirebaseFirestore.instance;

  /// Lấy danh sách Banners
  Stream<List<BannerModel>> getBanners() {
    return _db.collection('Banners')
        .where('ImageUrl', isNotEqualTo: '')           
        .where('ImageUrl', isNotEqualTo: null)             
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return BannerModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  /// Tạo Banner mới (ID tự động)
  Future<String> createBanner({
    required String imageUrl,
    required String targetScreen,
    required bool active,
  }) async {
    final docRef = _db.collection('Banners').doc();   // Tự động sinh ID

    await docRef.set({
      'ImageUrl': imageUrl,
      'TargetScreen': targetScreen,
      'Active': active,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  /// Cập nhật Banner
  Future<void> updateBanner(BannerModel banner) async {
    await _db.collection('Banners').doc(banner.id).update({
      'ImageUrl': banner.imageUrl,
      'TargetScreen': banner.targetScreen,
      'Active': banner.active,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Xóa Banner
  Future<void> deleteBanner(String id) async {
    await _db.collection('Banners').doc(id).delete();
  }
}