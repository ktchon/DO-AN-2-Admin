import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kc_admin_panel/Admin/models/products/product_model.dart';
import 'package:kc_admin_panel/Admin/models/report/report_model.dart';
import 'package:kc_admin_panel/Admin/models/report/review_model.dart';

class ReportRepository {
  final _db = FirebaseFirestore.instance;

  // Lấy tất cả báo cáo
  Stream<List<ReportModel>> getAllReports() {
    return _db.collection('Reports').orderBy('createdAt', descending: true).snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => ReportModel.fromMap(doc.data(), doc.id)).toList());
  }

  // Lấy chi tiết một Review theo reviewId
  Future<ReviewModel> getReviewById(String reviewId) async {
    final doc = await _db.collection('Reviews').doc(reviewId).get();
    if (!doc.exists) throw Exception("Review không tồn tại");
    return ReviewModel.fromMap(doc.data()!, reviewId);
  }

  // Xóa Review (và có thể xóa luôn report liên quan)
  Future<void> deleteReview(String reviewId) async {
    // Xóa review
    await _db.collection('Reviews').doc(reviewId).delete();

    // Xóa các report liên quan đến review này
    final reports = await _db.collection('Reports').where('reviewId', isEqualTo: reviewId).get();

    for (var doc in reports.docs) {
      await doc.reference.delete();
    }
  }

  // Lấy thông tin sản phẩm theo productId
  Future<ProductModel> getProductById(String productId) async {
    final doc = await _db.collection('Products').doc(productId).get();
    if (!doc.exists) throw Exception("Sản phẩm không tồn tại");
    return ProductModel.fromMap(doc.data()!, productId);
  }
}
