import 'package:flutter/material.dart';
import 'package:kc_admin_panel/Admin/controllers/report/report_controller.dart';
import 'package:kc_admin_panel/Admin/models/report/report_model.dart';
import 'package:kc_admin_panel/Admin/screens/admin_sidebar.dart';
import 'package:kc_admin_panel/Admin/screens/sidebar/admin_header.dart';
import 'report_detail_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final controller = ReportController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          const AdminSidebar(currentRoute: '/admin/reports'),
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
                        const Text('Quản lý Báo cáo Bình luận',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm báo cáo...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
                        ),
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
                                    offset: const Offset(0, 10)),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: StreamBuilder<List<ReportModel>>(
                                stream: controller.getAllReports(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                    return const Center(child: Text("Chưa có báo cáo nào"));
                                  }

                                  var reports = snapshot.data!;

                                  if (searchQuery.isNotEmpty) {
                                    reports = reports
                                        .where((r) =>
                                            r.reason.toLowerCase().contains(searchQuery) ||
                                            r.reviewId.toLowerCase().contains(searchQuery))
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

                                      // SỬA LỖI Ở ĐÂY:
                                      dataRowMinHeight: 65, // ← min
                                      dataRowMaxHeight: 65, // ← max phải bằng hoặc lớn hơn min

                                      columnSpacing: 60,
                                      horizontalMargin: 32,
                                      headingRowHeight: 60,

                                      border:
                                          TableBorder.all(color: const Color(0xFFE9ECEF), width: 1),

                                      columns: const [
                                        DataColumn(label: Text('Review ID')),
                                        DataColumn(label: Text('Lý do')),
                                        DataColumn(label: Text('Ngày báo cáo')),
                                        DataColumn(label: Text('Hành động')),
                                      ],

                                      rows: reports.map((report) {
                                        return DataRow(
                                          cells: [
                                            DataCell(Text(report.reviewId)),
                                            DataCell(Text(report.reason)),
                                            DataCell(Text(report.createdAt != null
                                                ? "${report.createdAt!.toDate().day}/${report.createdAt!.toDate().month}/${report.createdAt!.toDate().year}"
                                                : "—")),
                                            DataCell(
                                              IconButton(
                                                icon: const Icon(Icons.visibility,
                                                    color: Colors.blue),
                                                onPressed: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        ReportDetailScreen(report: report),
                                                  ),
                                                ),
                                                tooltip: "Xem chi tiết"
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
