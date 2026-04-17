import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:kc_admin_panel/Admin/screens/admin_sidebar.dart';
import 'package:kc_admin_panel/Admin/screens/dashboard/widgets/metric_card.dart';
import 'package:kc_admin_panel/Admin/screens/sidebar/admin_header.dart';

import '../../controllers/dashboard/dashboard_controller.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late final DashboardController _controller;

  // ── initState & dispose ─────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _controller = DashboardController();
    _controller.addListener(() => setState(() {})); // rebuild khi data thay đổi
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── Helper methods ─────────────────────────────────────────────────────────
  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M ₫';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K ₫';
    }
    return '${value.toStringAsFixed(0)} ₫';
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  Map<String, dynamic> _getStatusStyle(String status) {
    const map = {
      'pending': {'color': Color(0xFFBBDEFB)},
      'processing': {'color': Color(0xFFFFE0B2)},
      'shipped': {'color': Color(0xFFE1BEE7)},
      'delivered': {'color': Color(0xFFC8E6C9)},
      'cancelled': {'color': Color(0xFFFFCDD2)},
    };
    return map[status.toLowerCase()] ?? {'color': Color(0xFFEEEEEE)};
  }

  // ── Build Status Row ───────────────────────────────────────────────────────
  Widget _buildStatusRow(Color color, String status, String orders, String total) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(status),
            ],
          ),
          Text(orders),
          Text(total, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ── Weekly Sales Chart ─────────────────────────────────────────────────────
  Widget _buildWeeklySalesChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Doanh thu theo tuần',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 320,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: List.generate(7, (i) {
                  final values = _controller.weeklySalesData;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: values[i],
                        color: const Color(0xFF1E88E5),
                        width: 28,
                        borderRadius: BorderRadius.circular(6),
                      )
                    ],
                  );
                }),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _controller.weekDayLabels[value.toInt()],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Orders Status Chart ────────────────────────────────────────────────────
  Widget _buildOrdersStatusChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trạng thái đơn hàng',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),

          // Pie Chart
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 40,
                sections: _controller.orderStatusList
                    .where((s) => (s['count'] as int) > 0)
                    .map((s) => PieChartSectionData(
                          value: (s['count'] as int).toDouble(),
                          color: s['color'] as Color,
                          title: '${s['count']}',
                          radius: 65,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Header bảng
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.w500)),
              Text('Số đơn', style: TextStyle(fontWeight: FontWeight.w500)),
              Text('Tổng tiền', style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          const Divider(height: 20),

          // Dynamic status rows
          ..._controller.orderStatusList
              .where((s) => (s['count'] as int) > 0)
              .map((s) => _buildStatusRow(
                    s['color'] as Color,
                    s['label'] as String,
                    '${s['count']}',
                    _formatCurrency(s['total'] as double),
                  )),
        ],
      ),
    );
  }

  // ── Recent Orders Table ────────────────────────────────────────────────────
  Widget _buildRecentOrdersTable() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đơn hàng gần đây',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 50,
              headingTextStyle: const TextStyle(fontWeight: FontWeight.w600),
              columns: const [
                DataColumn(label: Text('Mã đơn')),
                DataColumn(label: Text('Ngày')),
                DataColumn(label: Text('Số sản phẩm')),
                DataColumn(label: Text('Trạng thái')),
                DataColumn(label: Text('Tổng tiền')),
              ],
              rows: _controller.recentOrdersList.map((order) {
                final statusStyle = _getStatusStyle(order.status);
                return DataRow(
                  cells: [
                    DataCell(Text(order.id)),
                    DataCell(Text(_formatDate(order.createdAt))),
                    DataCell(Text('${order.itemCount} sản phẩm')),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusStyle['color'],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          order.status,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    DataCell(Text(_formatCurrency(order.totalAmount))),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Main Build ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          // SIDEBAR
          const AdminSidebar(currentRoute: '/admin/dashboard'),

          // MAIN CONTENT
          Expanded(
            child: Column(
              children: [
                const AdminHeader(),
                const SizedBox(height: 20),

                // Dashboard Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bảng điều khiển',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 4 Metric Cards
                        GridView.count(
                          crossAxisCount: 4,
                          shrinkWrap: true,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 2.2,
                          children: [
                            MetricCard(
                              icon: Icons.attach_money,
                              title: 'Tổng doanh thu',
                              value: _formatCurrency(_controller.salesTotal),
                              change: '',
                              isIncrease: true,
                            ),
                            MetricCard(
                              icon: Icons.shopping_bag_outlined,
                              title: 'Giá trị đơn trung bình',
                              value: _formatCurrency(_controller.avgOrderValue),
                              change: '',
                              isIncrease: true,
                            ),
                            MetricCard(
                              icon: Icons.receipt_long_outlined,
                              title: 'Tổng số đơn hàng',
                              value: '${_controller.totalOrders}',
                              change: '',
                              isIncrease: true,
                            ),
                            MetricCard(
                              icon: Icons.people_outline,
                              title: 'Tổng số khách hàng',
                              value: '${_controller.totalUsers}',
                              change: '',
                              isIncrease: true,
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Charts Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildWeeklySalesChart(),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _buildOrdersStatusChart(),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Recent Orders
                        _buildRecentOrdersTable(),
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
