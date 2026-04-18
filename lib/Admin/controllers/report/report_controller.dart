import 'package:kc_admin_panel/Admin/models/products/product_model.dart';
import 'package:kc_admin_panel/Admin/models/report/review_model.dart';
import 'package:kc_admin_panel/data/report/report_repository.dart';
import '../../models/report/report_model.dart';

class ReportController {
  final repo = ReportRepository();

  Stream<List<ReportModel>> getAllReports() => repo.getAllReports();

  Future<ReviewModel> getReviewById(String reviewId) => repo.getReviewById(reviewId);

  Future<void> deleteReview(String reviewId) => repo.deleteReview(reviewId);
  Future<ProductModel> getProductById(String productId) => repo.getProductById(productId);
}
