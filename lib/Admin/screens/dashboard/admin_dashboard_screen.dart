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
  String _chartPeriod = 'week';

  @override
  void initState() {
    super.initState();
    _controller = DashboardController();
    _controller.addListener(_safeSetState);

    // Đảm bảo UI rebuild sau khi dữ liệu bắt đầu load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  void _safeSetState() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_safeSetState);
    _controller.dispose();
    super.dispose();
  }

  void _onPeriodChanged(String period) {
    setState(() {
      _chartPeriod = period;
    });
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M ₫';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}K ₫';
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
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
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

  // ─── Sales Chart with Period Filter ────────────────────────────────────────
  Widget _buildSalesChart() {
    List<double> salesData;
    List<String> labels;
    String chartTitle;

    switch (_chartPeriod) {
      case 'month':
        salesData = _controller.monthlySalesData;
        labels = _controller.monthLabels;
        chartTitle = 'Doanh thu theo tháng';
        break;
      case 'year':
        salesData = _controller.yearlySalesData;
        labels = _controller.yearLabels;
        chartTitle = 'Doanh thu theo năm';
        break;
      case 'week':
      default:
        salesData = _controller.weeklySalesData;
        labels = _controller.weekDayLabels;
        chartTitle = 'Doanh thu theo tuần';
    }

    // Kiểm tra dữ liệu có phải toàn 0 không
    final bool isAllZero = salesData.every((value) => value == 0.0);
    final double maxY = salesData.isNotEmpty
        ? salesData.reduce((a, b) => a > b ? a : b) * 1.1
        : 1000000; // giá trị mặc định khi chưa có dữ liệu

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + SegmentedButton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                chartTitle,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'week', label: Text('Tuần')),
                  ButtonSegment(value: 'month', label: Text('Tháng')),
                  ButtonSegment(value: 'year', label: Text('Năm')),
                ],
                selected: {_chartPeriod},
                onSelectionChanged: (Set<String> selection) {
                  _onPeriodChanged(selection.first);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Biểu đồ
          SizedBox(
            height: 320,
            child: isAllZero
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bar_chart, size: 60, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'Chưa có doanh thu trong kỳ này',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dữ liệu sẽ hiển thị khi có đơn hàng',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY,
                      minY: 0,
                      barGroups: List.generate(salesData.length, (i) {
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: salesData[i],
                              color: const Color(0xFF1E88E5),
                              width: _chartPeriod == 'week' ? 28 : 22,
                              borderRadius: BorderRadius.circular(6),
                            )
                          ],
                        );
                      }),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= labels.length) return const SizedBox();
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  labels[index],
                                  style: const TextStyle(fontSize: 11),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60,
                            getTitlesWidget: (value, meta) => Text(
                              _formatCurrency(value),
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: const FlGridData(show: true),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // Orders Status Chart
  Widget _buildOrdersStatusChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Trạng thái đơn hàng',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
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
                              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        ))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.w500)),
              Text('Số đơn', style: TextStyle(fontWeight: FontWeight.w500)),
              Text('Tổng tiền', style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          const Divider(height: 20),
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

  // Recent Orders Table
  Widget _buildRecentOrdersTable() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Đơn hàng gần đây',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
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
                        child: Text(order.status, style: const TextStyle(fontSize: 13)),
                      ),
                    ),
                    DataCell(Text(_formatCurrency(order.totalAmount ?? 0))),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Main Build ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          const AdminSidebar(currentRoute: '/admin/dashboard'),
          Expanded(
            child: Column(
              children: [
                const AdminHeader(),
                const SizedBox(height: 20),
                Expanded(
                  child: _controller.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _controller.error != null
                          ? Center(child: Text('Lỗi tải dữ liệu: ${_controller.error}'))
                          : SingleChildScrollView(
                              padding: const EdgeInsets.all(30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Bảng điều khiển',
                                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 24),

                                  // Metric Cards
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
                                          isIncrease: true),
                                      MetricCard(
                                          icon: Icons.shopping_bag_outlined,
                                          title: 'Giá trị đơn trung bình',
                                          value: _formatCurrency(_controller.avgOrderValue),
                                          change: '',
                                          isIncrease: true),
                                      MetricCard(
                                          icon: Icons.receipt_long_outlined,
                                          title: 'Tổng số đơn hàng',
                                          value: '${_controller.totalOrders}',
                                          change: '',
                                          isIncrease: true),
                                      MetricCard(
                                          icon: Icons.people_outline,
                                          title: 'Tổng số khách hàng',
                                          value: '${_controller.totalUsers}',
                                          change: '',
                                          isIncrease: true),
                                    ],
                                  ),

                                  const SizedBox(height: 30),

                                  // Charts
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(flex: 2, child: _buildSalesChart()),
                                      const SizedBox(width: 24),
                                      Expanded(child: _buildOrdersStatusChart()),
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
