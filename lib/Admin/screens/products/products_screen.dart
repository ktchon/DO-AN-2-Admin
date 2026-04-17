import 'package:flutter/material.dart';
import 'package:kc_admin_panel/Admin/controllers/product/product_controller.dart';
import 'package:kc_admin_panel/Admin/models/products/product_model.dart';
import 'package:kc_admin_panel/Admin/screens/admin_sidebar.dart';
import 'package:kc_admin_panel/Admin/screens/products/widgets/create_product.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ProductController controller = ProductController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          const AdminSidebar(currentRoute: '/admin/products'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Breadcrumb
                  const Text("Dashboard / Products", style: TextStyle(color: Colors.grey)),

                  const SizedBox(height: 8),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Sản phẩm",
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const CreateProductScreen()));
                            },
                            icon: const Icon(Icons.add, color: Colors.white,),
                            label: const Text("Thêm sản phẩm", style: TextStyle(color: Colors.white),),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 280,
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Tìm kiếm sản phẩm ...",
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              onChanged: (value) {
                                // TODO: Implement search
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Data Table
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async => setState(() {}),
                      child: StreamBuilder<List<ProductModel>>(
                        stream: controller.getProducts(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(child: Text("Lỗi: ${snapshot.error}"));
                          }

                          final products = snapshot.data ?? [];

                          if (products.isEmpty) {
                            return const Center(
                              child: Text("Chưa có sản phẩm nào", style: TextStyle(fontSize: 18)),
                            );
                          }

                          // === THAY THẾ TOÀN BỘ PHẦN Card chứa DataTable ===
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                      child: SingleChildScrollView(
                                        child: DataTable(
                                          headingRowHeight: 56,
                                          dataRowHeight: 76,
                                          horizontalMargin: 24,
                                          columnSpacing: 80,

                                          // Header màu
                                          headingRowColor:
                                              WidgetStateProperty.all(const Color(0xFFF8F9FA)),

                                          // Hover row
                                          dataRowColor:
                                              WidgetStateProperty.resolveWith<Color?>((states) {
                                            if (states.contains(WidgetState.hovered)) {
                                              return const Color(0xFFF5F7FA);
                                            }
                                            return Colors.white;
                                          }),

                                          // Border
                                          border: TableBorder(
                                            horizontalInside: const BorderSide(
                                                color: Color(0xFFEDEDED), width: 1),
                                            verticalInside: BorderSide.none,
                                            top: const BorderSide(
                                                color: Color(0xFFE0E0E0), width: 1),
                                            bottom: const BorderSide(
                                                color: Color(0xFFE0E0E0), width: 1),
                                          ),

                                          columns: const [
                                            DataColumn(
                                                label: Text("Product",
                                                    style: TextStyle(fontWeight: FontWeight.bold))),
                                            DataColumn(
                                                label: Text("Stock",
                                                    style: TextStyle(fontWeight: FontWeight.bold))),
                                            DataColumn(
                                                label: Text("Sold",
                                                    style: TextStyle(fontWeight: FontWeight.bold))),
                                            DataColumn(
                                                label: Text("Brand",
                                                    style: TextStyle(fontWeight: FontWeight.bold))),
                                            DataColumn(
                                                label: Text("Price",
                                                    style: TextStyle(fontWeight: FontWeight.bold))),
                                            DataColumn(
                                                label: Text("Date",
                                                    style: TextStyle(fontWeight: FontWeight.bold))),
                                            DataColumn(
                                                label: Text("Action",
                                                    style: TextStyle(fontWeight: FontWeight.bold))),
                                          ],

                                          rows: products.map((product) {
                                            return DataRow(
                                              onSelectChanged: (selected) {
                                                if (selected == true) {
                                                  _navigateToEditProduct(product);
                                                }
                                              },
                                              cells: [
                                                DataCell(
                                                  Row(
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius: BorderRadius.circular(8),
                                                        child: Image.network(
                                                          product.thumbnail,
                                                          width: 68,
                                                          height: 68,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (_, __, ___) => Container(
                                                            width: 68,
                                                            height: 68,
                                                            color: Colors.grey[100],
                                                            child: const Icon(
                                                              Icons.image_not_supported,
                                                              size: 28,
                                                              color: Colors.grey,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 16),
                                                      Expanded(
                                                        child: Text(
                                                          product.title,
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(fontSize: 15),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                DataCell(Text(product.stock.toString())),
                                                const DataCell(Text("0")),
                                                DataCell(Text(product.brand?.name ?? "N/A")),
                                                DataCell(
                                                    Text("${product.price.toStringAsFixed(0)}đ")),
                                                const DataCell(Text("28/07/2024")),
                                                DataCell(
                                                  Row(
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(Icons.edit,
                                                            color: Colors.blue),
                                                        onPressed: () =>
                                                            _navigateToEditProduct(product),
                                                            tooltip: "Tuỳ chọn",
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(Icons.delete,
                                                            color: Colors.red),
                                                        onPressed: () =>
                                                            _confirmDelete(context, product.id),
                                                            tooltip: "Xóa",
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String productId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Xóa sản phẩm?"),
        content: const Text("Hành động này không thể hoàn tác."),
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
      await controller.deleteProduct(productId);
    }
  }

  // Chuyển sang trang Edit
  void _navigateToEditProduct(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateProductScreen(productToEdit: product), // Truyền sản phẩm cần edit
      ),
    );
  }
}
