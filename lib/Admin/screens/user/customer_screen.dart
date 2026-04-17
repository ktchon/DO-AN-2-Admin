import 'package:flutter/material.dart';
import 'package:kc_admin_panel/Admin/controllers/user/user_controller.dart';
import 'package:kc_admin_panel/Admin/models/user/user_model.dart';
import 'package:kc_admin_panel/Admin/screens/admin_sidebar.dart';
import 'package:kc_admin_panel/Admin/screens/sidebar/admin_header.dart';
import 'customer_detail_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final controller = UserController();
  String searchQuery = '';

  // ==================== XÁC NHẬN XÓA ====================
  void _confirmDelete(String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Xóa khách hàng?"),
        content: const Text(
          "Hành động này sẽ xóa toàn bộ thông tin khách hàng bao gồm:\n"
          "• Thông tin cá nhân\n"
          "• Địa chỉ giao hàng\n"
          "• Lịch sử đơn hàng\n\n"
          "Không thể hoàn tác. Bạn chắc chắn muốn xóa?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Xóa",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await controller.deleteUser(userId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Đã xóa khách hàng thành công"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Lỗi khi xóa: ${e.toString()}"),
              backgroundColor: Colors.red,
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
          const AdminSidebar(currentRoute: '/admin/customers'),
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
                        const Text('Khách Hàng',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),

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
                              child: StreamBuilder<List<UserModel>>(
                                stream: controller.getUsers(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Text(
                                          "Lỗi: ${snapshot.error}",
                                          style: const TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    );
                                  }

                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  }

                                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                    return const Center(child: Text("Chưa có khách hàng nào"));
                                  }

                                  var users = snapshot.data!;

                                  // Tìm kiếm
                                  if (searchQuery.isNotEmpty) {
                                    users = users
                                        .where((u) =>
                                            u.fullName.toLowerCase().contains(searchQuery) ||
                                            u.email.toLowerCase().contains(searchQuery) ||
                                            u.phoneNumber.contains(searchQuery))
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
                                      columnSpacing: 60,
                                      horizontalMargin: 32,
                                      headingRowHeight: 60,
                                      dataRowMinHeight: 72,
                                      dataRowMaxHeight: 72,

                                      // Viền bảng đẹp
                                      border: TableBorder.all(
                                        color: const Color(0xFFE9ECEF),
                                        width: 1,
                                      ),

                                      columns: const [
                                        DataColumn(
                                          label: Text(
                                            'Customer',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600, fontSize: 15),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Email',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600, fontSize: 15),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Phone Number',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600, fontSize: 15),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Registered',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600, fontSize: 15),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Action',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600, fontSize: 15),
                                          ),
                                        ),
                                      ],

                                      rows: users.map((user) {
                                        return DataRow(
                                          cells: [
                                            // Customer
                                            DataCell(
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 26,
                                                    backgroundImage: user.profilePicture.isNotEmpty
                                                        ? NetworkImage(user.profilePicture)
                                                        : null,
                                                    child: user.profilePicture.isEmpty
                                                        ? const Icon(Icons.person, size: 28)
                                                        : null,
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Text(
                                                      user.fullName,
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 15,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Email
                                            DataCell(
                                              Text(
                                                user.email,
                                                style: const TextStyle(fontSize: 15),
                                              ),
                                            ),

                                            // Phone Number
                                            DataCell(
                                              Text(
                                                user.phoneNumber,
                                                style: const TextStyle(fontSize: 15),
                                              ),
                                            ),

                                            // Registered
                                            DataCell(
                                              Text(
                                                user.fullRegisteredDate, // Hoặc user.registeredDate nếu bạn muốn ngắn hơn
                                                style: const TextStyle(fontSize: 15),
                                              ),
                                            ),

                                            // Action
                                            DataCell(
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.visibility,
                                                        color: Colors.blue, size: 22),
                                                    tooltip: "Xem chi tiết",
                                                    onPressed: () => Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            CustomerDetailScreen(userId: user.id),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  IconButton(
                                                    icon: const Icon(Icons.delete,
                                                        color: Colors.redAccent, size: 22),
                                                    tooltip: "Xóa khách hàng",
                                                    onPressed: () => _confirmDelete(user.id),
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
