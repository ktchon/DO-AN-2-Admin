import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String productId;
  final String title;
  final String brandName;
  final String image;
  final double price;
  final int quantity;
  final Map<String, dynamic> selectedVariation;
  final String variationId;

  const OrderItem({
    required this.productId,
    required this.title,
    required this.brandName,
    required this.image,
    required this.price,
    required this.quantity,
    required this.selectedVariation,
    required this.variationId,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      title: map['title'] ?? '',
      brandName: map['brandName'] ?? '',
      image: map['image'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: (map['quantity'] ?? 1).toInt(),
      selectedVariation: Map<String, dynamic>.from(map['selectedVariation'] ?? {}),
      variationId: map['variationId'] ?? '',
    );
  }
}

class OrderModel {
  final String id;
  final String userId;
  final String status;
  final double totalAmount;
  final String paymentMethod;
  final DateTime orderDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deliveryDate;
  final List<OrderItem> items;
  final Map<String, dynamic> address;
  final String? couponId;
  final String? cancelReason;
  final String? ghnStatus;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.status,
    required this.totalAmount,
    required this.paymentMethod,
    required this.orderDate,
    required this.createdAt,
    this.updatedAt,
    this.deliveryDate,
    required this.items,
    required this.address,
    this.couponId,
    this.cancelReason,
    this.ghnStatus,
  });

  factory OrderModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: data['id'] ?? doc.id,
      userId: data['userId'] ?? '',
      status: data['status'] ?? 'pending',
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      paymentMethod: data['paymentMethod'] ?? '',
      orderDate: (data['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      deliveryDate: (data['deliveryDate'] as Timestamp?)?.toDate(),
      items: (data['items'] as List<dynamic>? ?? [])
          .map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      address: Map<String, dynamic>.from(data['address'] ?? {}),
      couponId: data['couponId'],
      cancelReason: data['cancelReason'],
      ghnStatus: data['ghnStatus'],
    );
  }

  int get itemCount => items.fold(0, (sum, e) => sum + e.quantity);
}