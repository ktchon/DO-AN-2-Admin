import 'package:flutter/material.dart';
import 'package:kc_admin_panel/Admin/controllers/order/order_controller.dart';
import 'package:kc_admin_panel/Admin/models/order/order_model.dart';
import 'package:kc_admin_panel/Admin/screens/admin_sidebar.dart';
import 'package:kc_admin_panel/Admin/screens/sidebar/admin_header.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final controller = OrderController();
  String searchQuery = '';

  Future<void> _confirmDelete(BuildContext context, OrderModel order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xoá', style: TextStyle(fontWeight: FontWeight.bold)),
        content:
            Text('Bạn có chắc muốn xoá đơn hàng ${order.id}?\nHành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xoá', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await controller.deleteOrder(order.userId, order.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã xoá đơn hàng ${order.id}'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          const AdminSidebar(currentRoute: '/admin/orders'),
          Expanded(
            child: Column(
              children: [
                const AdminHeader(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Orders',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),

                        // Search
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Search Orders...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
                        ),
                        const SizedBox(height: 20),

                        // Bảng Orders
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: StreamBuilder<List<OrderModel>>(
                                stream: controller.getAllOrders(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                    return const Center(child: Text("Chưa có đơn hàng nào"));
                                  }

                                  var orders = snapshot.data!;
                                  if (searchQuery.isNotEmpty) {
                                    orders = orders
                                        .where((o) => o.id.toLowerCase().contains(searchQuery))
                                        .toList();
                                  }

                                  return SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: DataTable(
                                      headingRowColor:
                                          WidgetStateProperty.all(const Color(0xFFF1F3F5)),
                                      dataRowColor: WidgetStateProperty.resolveWith(
                                        (states) => states.contains(WidgetState.hovered)
                                            ? const Color(0xFFF8F9FA)
                                            : null,
                                      ),
                                      dataRowMinHeight: 65,
                                      dataRowMaxHeight: 65,
                                      columnSpacing: 60,
                                      horizontalMargin: 32,
                                      headingRowHeight: 60,
                                      border:
                                          TableBorder.all(color: const Color(0xFFE9ECEF), width: 1),
                                      columns: const [
                                        DataColumn(
                                            label: Text('Order ID',
                                                style: TextStyle(fontWeight: FontWeight.w600))),
                                        DataColumn(
                                            label: Text('Date',
                                                style: TextStyle(fontWeight: FontWeight.w600))),
                                        DataColumn(
                                            label: Text('Items',
                                                style: TextStyle(fontWeight: FontWeight.w600))),
                                        DataColumn(
                                            label: Text('Status',
                                                style: TextStyle(fontWeight: FontWeight.w600))),
                                        DataColumn(
                                            label: Text('Amount',
                                                style: TextStyle(fontWeight: FontWeight.w600))),
                                        DataColumn(
                                            label: Text('Action',
                                                style: TextStyle(fontWeight: FontWeight.w600))),
                                      ],
                                      rows: orders.map((order) {
                                        return DataRow(
                                          cells: [
                                            DataCell(Text(order.id,
                                                style: const TextStyle(color: Colors.blue))),
                                            DataCell(Text(order.orderDate != null
                                                ? "${order.orderDate!.toDate().day}/${order.orderDate!.toDate().month}/${order.orderDate!.toDate().year}"
                                                : "—")),
                                            DataCell(Text("${order.items.length} Items")),
                                            DataCell(
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: order.statusColor.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  order.statusDisplay,
                                                  style: TextStyle(
                                                      color: order.statusColor,
                                                      fontWeight: FontWeight.w500),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                                Text("${order.totalAmount.toStringAsFixed(0)}đ")),
                                            DataCell(
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // Nút xem chi tiết
                                                  IconButton(
                                                    icon: const Icon(Icons.visibility,
                                                        color: Colors.blue),
                                                    tooltip: 'Xem chi tiết',
                                                    onPressed: () => Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (_) =>
                                                              OrderDetailScreen(order: order, orderId: null,)),
                                                    ),
                                                  ),
                                                  // Nút xoá
                                                  IconButton(
                                                    icon: const Icon(Icons.delete_outline,
                                                        color: Colors.red),
                                                    tooltip: 'Xoá đơn hàng',
                                                    onPressed: () => _confirmDelete(context, order),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
