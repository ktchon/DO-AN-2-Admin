import 'package:flutter/material.dart';
import 'package:kc_admin_panel/Admin/controllers/order/order_controller.dart';
import 'package:kc_admin_panel/Admin/models/order/order_model.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final controller = OrderController();
  late String currentStatus;
  bool _isUpdating = false;
  Map<String, dynamic>? _userInfo;

  // Các trạng thái hợp lệ
  static const _statuses = [
    {'value': 'pending', 'label': 'Pending'},
    {'value': 'processing', 'label': 'Processing'},
    {'value': 'shipped', 'label': 'Shipped'},
    {'value': 'delivered', 'label': 'Delivered'},
    {'value': 'cancelled', 'label': 'Cancelled'},
  ];

  @override
  void initState() {
    super.initState();
    currentStatus = widget.order.status;
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final info = await controller.getUserInfo(widget.order.userId);
    if (mounted) setState(() => _userInfo = info);
  }

  Future<void> _updateStatus(String newStatus) async {
    if (newStatus == currentStatus) return;
    setState(() => _isUpdating = true);
    try {
      await controller.updateOrderStatus(widget.order.userId, widget.order.id, newStatus);
      setState(() => currentStatus = newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cập nhật trạng thái thành công'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'shipped':
        return const Color(0xFF7C3AED); // purple
      case 'processing':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final address = order.address;

    // Lấy timeline từ order nếu có
    final timeline = order.timeline ?? [];

    return Scaffold(
      backgroundColor: Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Color(0xFF34C759),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20,color: Colors.white,),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(order.id, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================== LEFT COLUMN ====================
            Expanded(
              flex: 7,
              child: Column(
                children: [
                  // Order Information
                  _buildCard(
                    title: "Thông tin đơn hàng",
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _infoColumn(
                          "Ngày đặt",
                          order.orderDate != null
                              ? "${order.orderDate!.toDate().day}/${order.orderDate!.toDate().month}/${order.orderDate!.toDate().year}"
                              : "—",
                        ),
                        const SizedBox(width: 40),
                        _infoColumn("Số lượng", "${order.items.length}"),
                        const SizedBox(width: 40),

                        // Status dropdown đẹp
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Trạng thái",
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            const SizedBox(height: 4),
                            _isUpdating
                                ? const SizedBox(
                                    width: 140,
                                    height: 38,
                                    child: Center(
                                        child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(strokeWidth: 2))),
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: _statusColor(currentStatus).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: _statusColor(currentStatus).withOpacity(0.3)),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: currentStatus,
                                        icon: Icon(Icons.keyboard_arrow_down,
                                            color: _statusColor(currentStatus), size: 18),
                                        style: TextStyle(
                                          color: _statusColor(currentStatus),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                        items: _statuses
                                            .map((s) => DropdownMenuItem<String>(
                                                  value: s['value'],
                                                  child: Text(s['label']!),
                                                ))
                                            .toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            _updateStatus(val);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                          ],
                        ),

                        const SizedBox(width: 40),
                        _infoColumn("Tổng tiền", "${order.totalAmount.toStringAsFixed(0)}đ"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Items
                  _buildCard(
                    title: "Số lượng",
                    child: Column(
                      children: order.items
                          .map((item) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        item.image,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 50,
                                          height: 50,
                                          color: Colors.grey.shade200,
                                          child: const Icon(Icons.image_not_supported, size: 20),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item.title,
                                              style: const TextStyle(fontWeight: FontWeight.w500)),
                                          Text(item.brandName,
                                              style: const TextStyle(
                                                  color: Colors.grey, fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      "${item.price.toStringAsFixed(0)}đ  x ${item.quantity}  = ${(item.price * item.quantity).toStringAsFixed(0)}đ",
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Summary
                  _buildCard(
                    title: "Tóm tắt",
                    child: Column(
                      children: [
                        _summaryRow("Tạm tính", "${order.totalAmount.toStringAsFixed(0)}đ"),
                        _summaryRow("Giảm giá", "0đ"),
                        _summaryRow("Phí vận chuyển", "0đ"),
                        _summaryRow("Thuế", "0đ"),
                        const Divider(),
                        _summaryRow("Tổng cộng", "${order.totalAmount.toStringAsFixed(0)}đ",
                            isBold: true),
                      ],
                    ),
                  ),

                  // Transactions (Payment info)
                  if (order.paymentMethod.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildCard(
                      title: "Phương thức thanh toán",
                      child: Row(
                        children: [
                          // Icon payment method
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              order.paymentMethod.toLowerCase() == 'paypal'
                                  ? Icons.payment
                                  : Icons.money,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Thanh toán bằng ${order.paymentMethod}",
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                if (order.orderDate != null)
                                  Text(
                                    "Ngày: ${order.orderDate!.toDate().day}/${order.orderDate!.toDate().month}/${order.orderDate!.toDate().year}",
                                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            "Tổng cộng: ${order.totalAmount.toStringAsFixed(0)}đ",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Timeline (nếu có)
                  if (timeline.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildCard(
                      title: "Lịch sử đơn hàng",
                      child: Column(
                        children: timeline.asMap().entries.map((entry) {
                          final i = entry.key;
                          final t = entry.value as Map<String, dynamic>;
                          final isLast = i == timeline.length - 1;
                          final time = t['time'] != null ? (t['time'] as dynamic).toDate() : null;
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: i == 0 ? Colors.blue : Colors.grey.shade400,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  if (!isLast)
                                    Container(width: 2, height: 36, color: Colors.grey.shade300),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(t['title'] ?? '',
                                          style: const TextStyle(fontWeight: FontWeight.w500)),
                                      if (time != null)
                                        Text(
                                          "${time.hour}:${time.minute.toString().padLeft(2, '0')} - ${time.day}/${time.month}/${time.year}",
                                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 30),

            // ==================== RIGHT COLUMN ====================
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  // Customer
                  _buildCard(
                    title: "Khách hàng",
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: _userInfo?['ProfilePicture'] != null
                              ? NetworkImage(_userInfo!['ProfilePicture'])
                              : const NetworkImage("https://i.pravatar.cc/150"),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _userInfo != null
                                  ? "${_userInfo!['FirstName'] ?? ''} ${_userInfo!['LastName'] ?? ''}"
                                      .trim()
                                  : "—",
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              _userInfo?['Email'] ?? '—',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Contact Person
                  _buildCard(
                    title: "Người liên hệ",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_userInfo != null
                            ? "${_userInfo!['FirstName'] ?? ''} ${_userInfo!['LastName'] ?? ''}"
                                .trim()
                            : "—"),
                        Text(_userInfo?['Email'] ?? '—',
                            style: const TextStyle(color: Colors.grey)),
                        Text(_userInfo?['PhoneNumber'] ?? '—',
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Shipping Address
                  _buildCard(
                    title: "Địa chỉ giao hàng",
                    child: address != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (address['Name'] != null)
                                Text(address['Name'],
                                    style: const TextStyle(fontWeight: FontWeight.w500)),
                              if (address['PhoneNumber'] != null)
                                Text(address['PhoneNumber'],
                                    style: const TextStyle(color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(
                                [
                                  address['Street'],
                                  address['City'],
                                  address['State'],
                                  address['Country'],
                                  address['PostalCode'],
                                ].where((e) => e != null && e.toString().isNotEmpty).join(', '),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          )
                        : const Text("Không có địa chỉ", style: TextStyle(color: Colors.grey)),
                  ),

                  const SizedBox(height: 24),

                  // Billing Address (dùng cùng address vì không có trường riêng)
                  _buildCard(
                    title: "Địa chỉ thanh toán",
                    child: address != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (address['Name'] != null)
                                Text(address['Name'],
                                    style: const TextStyle(fontWeight: FontWeight.w500)),
                              Text(
                                [
                                  address['Street'],
                                  address['City'],
                                  address['State'],
                                  address['Country'],
                                ].where((e) => e != null && e.toString().isNotEmpty).join(', '),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          )
                        : const Text("Không có địa chỉ", style: TextStyle(color: Colors.grey)),
                  ),

                  // Cancel reason (nếu có)
                  if (order.cancelReason != null && order.cancelReason!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildCard(
                      title: "Lý do huỷ đơn",
                      child: Text(
                        order.cancelReason!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      color: Color(0xFFFFFFFF),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFD1D1D6), width: 1),
      ),
      child: SizedBox(
        width: double.infinity, 
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
      ),
    );
  }

  Widget _infoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
