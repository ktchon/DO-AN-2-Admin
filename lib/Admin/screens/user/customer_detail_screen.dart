import 'package:flutter/material.dart';
import 'package:kc_admin_panel/Admin/controllers/user/user_controller.dart';
import 'package:kc_admin_panel/Admin/models/order/order_model.dart';
import 'package:kc_admin_panel/Admin/models/user/address_model.dart';
import 'package:kc_admin_panel/Admin/models/user/user_model.dart';

class CustomerDetailScreen extends StatefulWidget {
  final String userId;
  const CustomerDetailScreen({super.key, required this.userId});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  final controller = UserController();
  late Future<UserModel> userFuture;
  late Stream<List<AddressModel>> addressesStream;
  late Stream<List<OrderModel>> ordersStream; // ← Thêm dòng này

  @override
  void initState() {
    super.initState();
    userFuture = controller.getUserById(widget.userId);
    addressesStream = controller.getUserAddresses(widget.userId);
    ordersStream = controller.getOrdersByUser(widget.userId); // ← Thêm dòng này
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 239, 238, 238),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Chi tiết khách hàng"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<UserModel>(
        future: userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Không tìm thấy khách hàng"));
          }

          final user = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(30),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ==================== LEFT COLUMN ====================
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      /// USER INFO CARD
                      Card(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundImage: user.profilePicture.isNotEmpty
                                        ? NetworkImage(user.profilePicture)
                                        : null,
                                    child: user.profilePicture.isEmpty
                                        ? const Icon(Icons.person, size: 40)
                                        : null,
                                  ),
                                  const SizedBox(width: 20),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.fullName,
                                        style: const TextStyle(
                                            fontSize: 22, fontWeight: FontWeight.bold),
                                      ),
                                      Text(user.email),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              _infoRow("Tên người dùng", user.username.isNotEmpty ? user.username : "—"),
                              _infoRow(
                                  "Số điện thoại", user.phoneNumber.isNotEmpty ? user.phoneNumber : "—"),
                              _infoRow("Quốc gia", "Việt Nam"),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// SHIPPING ADDRESS CARD
                      Expanded(
                        child: Card(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Địa chỉ giao hàng",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: StreamBuilder<List<AddressModel>>(
                                    stream: addressesStream,
                                    builder: (context, addrSnapshot) {
                                      if (!addrSnapshot.hasData || addrSnapshot.data!.isEmpty) {
                                        return const Center(child: Text("không tìm thấy địa chỉ"));
                                      }

                                      final addresses = addrSnapshot.data!;

                                      return ListView.builder(
                                        itemCount: addresses.length,
                                        itemBuilder: (_, index) {
                                          final addr = addresses[index];
                                          return Card(
                                            color: const Color.fromARGB(255, 240, 239, 239),
                                            margin: const EdgeInsets.only(bottom: 10),
                                            child: ListTile(
                                              title: Text(addr.name),
                                              subtitle: Text(
                                                  "${addr.street}, ${addr.city}, ${addr.country}"),
                                              trailing: addr.isSelected
                                                  ? const Chip(label: Text("Mặc định"))
                                                  : null,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 30),

                /// ==================== RIGHT COLUMN - ORDERS====================
                Expanded(
                  flex: 3,
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Đơn hàng",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),

                          /// Orders List thật từ Firestore
                          Expanded(
                            child: StreamBuilder<List<OrderModel>>(
                              stream: ordersStream,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }

                                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return const Center(
                                    child: Text("Khách hàng chưa có đơn hàng nào"),
                                  );
                                }

                                final orders = snapshot.data!;

                                return ListView.builder(
                                  itemCount: orders.length,
                                  itemBuilder: (context, index) {
                                    final order = orders[index];
                                    return Card(
                                      color: const Color.fromARGB(255, 240, 239, 239),
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: ListTile(
                                        leading: const Icon(Icons.receipt_long, color: Colors.blue),
                                        title: Text("Đơn hàng ${order.id}",
                                            style: const TextStyle(fontWeight: FontWeight.w500)),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                "Tổng cộng: ${order.totalAmount.toStringAsFixed(0)}vnđ"),
                                            Text(
                                              order.orderDate != null
                                                  ? "${order.orderDate!.toDate().day}/${order.orderDate!.toDate().month}/${order.orderDate!.toDate().year}"
                                                  : "",
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        trailing: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: order.statusColor.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            order.statusDisplay,
                                            style: TextStyle(
                                              color: order.statusColor,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          // TODO: Mở chi tiết đơn hàng
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                                content: Text("Chi tiết đơn hàng ${order.id}")),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
