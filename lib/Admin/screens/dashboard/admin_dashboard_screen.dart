// lib/Admin/screens/dashboard/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:kc_admin_panel/Admin/screens/admin_sidebar.dart';
import 'package:kc_admin_panel/Admin/screens/dashboard/widgets/metric_card.dart';
import '../../controllers/dashboard/dashboard_controller.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late final DashboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DashboardController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          // ==================== SIDEBAR ====================
          const AdminSidebar(currentRoute: '/admin/dashboard'),

          // ==================== MAIN CONTENT ====================
          Expanded(
            child: Column(
              children: [
                // Header
                _buildHeader(),

                // Dashboard Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Dashboard',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),

                        const SizedBox(height: 24),

                        // 4 Metric Cards
                        GridView.count(
                          crossAxisCount: 4,
                          shrinkWrap: true,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 2.2,
                          children: const [
                            MetricCard(
                              icon: Icons.attach_money,
                              title: 'Sales total',
                              value: '\$30,117.28',
                              change: '↑ 25%',
                              isIncrease: true,
                            ),
                            MetricCard(
                              icon: Icons.shopping_bag_outlined,
                              title: 'Average Order Value',
                              value: '\$654.72',
                              change: '↓ 15%',
                              isIncrease: false,
                            ),
                            MetricCard(
                              icon: Icons.receipt_long_outlined,
                              title: 'Total Orders',
                              value: '46',
                              change: '↑ 44%',
                              isIncrease: true,
                            ),
                            MetricCard(
                              icon: Icons.people_outline,
                              title: 'Visitors',
                              value: '39',
                              change: '↑ 2%',
                              isIncrease: true,
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Charts Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Weekly Sales
                            Expanded(
                              flex: 2,
                              child: _buildWeeklySalesChart(),
                            ),
                            const SizedBox(width: 24),
                            // Orders Status
                            Expanded(
                              child: _buildOrdersStatusChart(),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Recent Orders Table
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

  Widget _buildHeader() {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search anything...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                filled: true,
                fillColor: Color(0xFFF8F9FA),
                contentPadding: EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const SizedBox(width: 20),
          const Icon(Icons.notifications_none, size: 28),
          const SizedBox(width: 30),
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFF1E88E5),
            child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('App Admin', style: TextStyle(fontWeight: FontWeight.w600)),
              Text('support@codingwitht.com', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title,
      {bool isSelected = false, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.white : Colors.grey[700]),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      tileColor: isSelected ? const Color(0xFF1E88E5) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: const Color(0xFF1E88E5),
    );
  }

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
          const Text('Weekly Sales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          SizedBox(
            height: 320,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: List.generate(5, (i) {
                  final values = [180, 2100, 3900, 800, 0]; // demo
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                          toY: values[i].toDouble(),
                          color: const Color(0xFF1E88E5),
                          width: 35,
                          borderRadius: BorderRadius.circular(6))
                    ],
                  );
                }),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(['Mon', 'Tue', 'Wed', 'Thu', 'Fri'][value.toInt()]),
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
          const Text('Orders Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),

          // Pie Chart
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(value: 26, color: Colors.blue, title: '26', radius: 65),
                  PieChartSectionData(value: 10, color: Colors.green, title: '10', radius: 65),
                  PieChartSectionData(value: 5, color: Colors.purple, title: '5', radius: 65),
                  PieChartSectionData(value: 5, color: Colors.orange, title: '5', radius: 65),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Bảng Orders Status (giống ảnh bạn gửi)
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Status', style: TextStyle(fontWeight: FontWeight.w500)),
              Text('Orders', style: TextStyle(fontWeight: FontWeight.w500)),
              Text('Total', style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          const Divider(height: 20),

          _buildStatusRow(Colors.purple, 'Shipped', '5', '\$5823.36'),
          _buildStatusRow(Colors.green, 'Delivered', '10', '\$3049.40'),
          _buildStatusRow(Colors.blue, 'Pending', '26', '\$6864.40'),
          _buildStatusRow(Colors.orange, 'Processing', '5', '\$14380.12'),
        ],
      ),
    );
  }

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
          const Text('Recent Orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 50,
              headingTextStyle: const TextStyle(fontWeight: FontWeight.w600),
              columns: const [
                DataColumn(label: Text('Order ID')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Items')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Amount')),
              ],
              rows: _controller.recentOrders.map((order) {
                return DataRow(
                  cells: [
                    DataCell(Text(order['id'] ?? '')),
                    const DataCell(Text('26 Jul 2024')),
                    const DataCell(Text('2 Items')),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: order['statusColor'],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          order['status'] ?? '',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    DataCell(Text(order['amount'] ?? '')),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
