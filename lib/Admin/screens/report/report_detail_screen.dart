import 'package:flutter/material.dart';
import 'package:kc_admin_panel/Admin/controllers/report/report_controller.dart';
import 'package:kc_admin_panel/Admin/models/products/product_model.dart';
import 'package:kc_admin_panel/Admin/models/report/report_model.dart';
import 'package:kc_admin_panel/Admin/models/report/review_model.dart';

class ReportDetailScreen extends StatefulWidget {
  final ReportModel report;
  const ReportDetailScreen({super.key, required this.report});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final controller = ReportController();
  late Future<ReviewModel> reviewFuture;

  @override
  void initState() {
    super.initState();
    reviewFuture = controller.getReviewById(widget.report.reviewId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Color(0xFF34C759),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20,color: Colors.white,),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Report #${widget.report.id.substring(0, 8)}", style: const TextStyle(color: Colors.white),),
      ),
      body: FutureBuilder<ReviewModel>(
        future: reviewFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Không tìm thấy bình luận"));
          }

          final review = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(30),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================== LEFT COLUMN ====================
                Expanded(
                  flex: 6,
                  child: Column(
                    children: [
                      // Report Information
                      _buildCard(
                        title: "Thông tin Báo cáo",
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _infoRow("Lý do báo cáo", widget.report.reason),
                            _infoRow(
                                "Ngày báo cáo",
                                widget.report.createdAt != null
                                    ? "${widget.report.createdAt!.toDate().day}/${widget.report.createdAt!.toDate().month}/${widget.report.createdAt!.toDate().year}"
                                    : "—"),
                            _infoRow("Review ID", widget.report.reviewId),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Review Content
                      _buildCard(
                        title: "Nội dung Bình luận",
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: review.userAvatar.isNotEmpty
                                      ? NetworkImage(review.userAvatar)
                                      : null,
                                  child:
                                      review.userAvatar.isEmpty ? const Icon(Icons.person) : null,
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(review.userName,
                                        style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text("Đánh giá: ${review.rating} ★",
                                        style: const TextStyle(color: Colors.orange)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              review.comment,
                              style: const TextStyle(fontSize: 16, height: 1.5),
                            ),
                            if (review.images.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              const Text("Hình ảnh đính kèm:",
                                  style: TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: review.images.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(review.images[index],
                                            height: 100, fit: BoxFit.cover),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 30),

                // ==================== RIGHT COLUMN ====================
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      // ==================== PRODUCT INFORMATION (ĐẦY ĐỦ) ====================
                      _buildCard(
                        title: "Sản phẩm",
                        child: FutureBuilder<ProductModel>(
                          future: controller.getProductById(review.productId),
                          builder: (context, productSnapshot) {
                            if (productSnapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (productSnapshot.hasError || !productSnapshot.hasData) {
                              return const Text("Không tìm thấy thông tin sản phẩm");
                            }

                            final product = productSnapshot.data!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Ảnh sản phẩm
                                Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      product.thumbnail,
                                      height: 180,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.image_not_supported, size: 80),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Tên sản phẩm
                                Text(
                                  product.title,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),

                                // Giá
                                Text(
                                  "${product.price.toStringAsFixed(0)} vnđ",
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green),
                                ),
                                const SizedBox(height: 16),

                                _infoRow("Brand", product.brand?.name ?? "—"),
                                _infoRow("Category ID", product.categoryId),
                                _infoRow(
                                    "Description",
                                    product.description.isNotEmpty
                                        ? product.description
                                        : "Không có mô tả"),

                                if (review.variation != null && review.variation!.isNotEmpty)
                                  _infoRow(
                                    "Variation",
                                    "${review.variation!['Color'] ?? ''} - ${review.variation!['Size'] ?? ''}",
                                  ),
                              ],
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Action Buttons
                      _buildCard(
                        title: "Hành động",
                        child: Column(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _deleteReview(review.id),
                              icon: const Icon(Icons.delete, color: Colors.white),
                              label: const Text("Xóa Bình luận này", style: TextStyle(color: Colors.white),),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                minimumSize: const Size(double.infinity, 50),
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                              label: const Text("Quay lại"),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 120, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _deleteReview(String reviewId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Xóa bình luận?"),
        content: const Text(
            "Hành động này không thể hoàn tác. Bạn có chắc chắn muốn xóa bình luận này không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Hủy")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await controller.deleteReview(reviewId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Đã xóa bình luận thành công"), backgroundColor: Colors.green),
          );
          Navigator.pop(context); // Quay về danh sách báo cáo
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: ${e.toString()}"), backgroundColor: Colors.red),
        );
      }
    }
  }
}
