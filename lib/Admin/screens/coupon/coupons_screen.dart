import 'package:flutter/material.dart';
import 'package:kc_admin_panel/Admin/models/coupons/coupon_model.dart';
import '../../controllers/coupon/coupon_controller.dart';
import '../admin_sidebar.dart';
import '../sidebar/admin_header.dart';

class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  final controller = CouponController();

  // ================= CREATE =================
  void _showCreateDialog() {
    final idController = TextEditingController();
    final codeController = TextEditingController();
    final valueController = TextEditingController();
    final minController = TextEditingController();
    final maxController = TextEditingController();
    final limitController = TextEditingController();

    String type = "percentage";
    bool isActive = true;
    DateTime expiry = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text("Tạo Khuyến Mãi"),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                          controller: idController,
                          decoration: const InputDecoration(labelText: "ID")),
                      TextField(
                          controller: codeController,
                          decoration: const InputDecoration(labelText: "Code")),
                      TextField(
                          controller: valueController,
                          decoration: const InputDecoration(labelText: "Value")),
                      DropdownButtonFormField(
                        value: type,
                        items: const [
                          DropdownMenuItem(value: "percentage", child: Text("Percentage")),
                          DropdownMenuItem(value: "fixed", child: Text("Fixed")),
                        ],
                        onChanged: (v) => setStateDialog(() => type = v!),
                      ),
                      TextField(
                          controller: minController,
                          decoration: const InputDecoration(labelText: "Min Order")),
                      TextField(
                          controller: maxController,
                          decoration: const InputDecoration(labelText: "Max Discount")),
                      TextField(
                          controller: limitController,
                          decoration: const InputDecoration(labelText: "Usage Limit")),
                      SwitchListTile(
                        value: isActive,
                        onChanged: (v) => setStateDialog(() => isActive = v),
                        title: const Text("Active"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                            initialDate: expiry,
                          );
                          if (picked != null) {
                            setStateDialog(() => expiry = picked);
                          }
                        },
                        child: Text("Expiry: ${expiry.toString().split(' ')[0]}"),
                      )
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await controller.createCoupon(
                        CouponModel(
                          id: idController.text.trim(),
                          code: codeController.text.trim(),
                          value: double.tryParse(valueController.text) ?? 0,
                          type: type,
                          minOrder: double.tryParse(minController.text) ?? 0,
                          maxDiscount: double.tryParse(maxController.text) ?? 0,
                          usageLimit: int.tryParse(limitController.text) ?? 0,
                          usedCount: 0,
                          isActive: isActive,
                          expiryDate: expiry,
                        ),
                      );

                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                  child: const Text("Create"),
                )
              ],
            );
          },
        );
      },
    );
  }

  // ================= DELETE =================
  void _confirmDelete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xóa coupon?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Xóa")),
        ],
      ),
    );

    if (confirm == true) {
      await controller.deleteCoupon(id);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Nền nhạt giống ảnh
      body: Row(
        children: [
          const AdminSidebar(currentRoute: '/admin/coupons'),
          Expanded(
            child: Column(
              children: [
                const AdminHeader(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(30, 20, 30, 30), // Giảm padding trên
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Khuyến mãi",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _showCreateDialog,
                              icon: const Icon(Icons.add,color: Colors.white,),
                              label: const Text("Tạo khuyến mãi", style: TextStyle(color: Colors.white),),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                backgroundColor: Colors.green.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // === BẢNG FULL LỚN ===
                        Expanded(
                          child: Container(
                            width: double.infinity, // Full width
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
                              child: StreamBuilder<List<CouponModel>>(
                                stream: controller.getCoupons(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  final coupons = snapshot.data!;

                                  return SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: DataTable(
                                      headingRowColor: WidgetStateProperty.all(
                                        const Color(0xFFF1F3F5), // Màu header giống ảnh
                                      ),
                                      dataRowColor: WidgetStateProperty.resolveWith(
                                        (states) => states.contains(WidgetState.selected)
                                            ? Colors.blue.shade50
                                            : null,
                                      ),
                                      columnSpacing: 60, // Tăng khoảng cách giữa các cột
                                      horizontalMargin: 32,
                                      headingRowHeight: 60,
                                      dataRowMinHeight: 65,
                                      dataRowMaxHeight: 65,

                                      // Viền bảng & ô
                                      border: TableBorder.all(
                                        color: const Color(0xFFE9ECEF),
                                        width: 1,
                                      ),

                                      columns: const [
                                        DataColumn(
                                          label: Text(
                                            'Code',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Value',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Type',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Active',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Action',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ],
                                      rows: coupons.map((c) {
                                        return DataRow(
                                          cells: [
                                            DataCell(
                                              Text(
                                                c.code,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                            DataCell(Text(
                                              c.value
                                                  .toStringAsFixed(c.type == 'percentage' ? 0 : 0),
                                              style: const TextStyle(fontSize: 15),
                                            )),
                                            DataCell(Text(
                                              c.type.toUpperCase(),
                                              style: const TextStyle(fontSize: 15),
                                            )),
                                            DataCell(
                                              Switch(
                                                value: c.isActive,
                                                activeColor: Colors.green,
                                                activeTrackColor: Colors.green.shade200,
                                                onChanged: (v) {
                                                  controller.updateCoupon(
                                                    CouponModel(
                                                      id: c.id,
                                                      code: c.code,
                                                      value: c.value,
                                                      type: c.type,
                                                      minOrder: c.minOrder,
                                                      maxDiscount: c.maxDiscount,
                                                      usageLimit: c.usageLimit,
                                                      usedCount: c.usedCount,
                                                      isActive: v,
                                                      expiryDate: c.expiryDate,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            DataCell(
                                              IconButton(
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.redAccent, size: 22),
                                                onPressed: () => _confirmDelete(c.id),
                                                tooltip: "Xóa",
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
