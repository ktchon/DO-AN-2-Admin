import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderModel {
  final String id;
  final String userId;
  final double totalAmount;
  final String status;
  final String paymentMethod;
  final Timestamp? orderDate;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final String? ghnStatus;
  final String? cancelReason;
  final List<OrderItem> items;
  final Map<String, dynamic>? address;
  final List<dynamic>? timeline; // ← Thêm mới

  OrderModel({
    required this.id,
    required this.userId,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    this.orderDate,
    this.createdAt,
    this.updatedAt,
    this.ghnStatus,
    this.cancelReason,
    required this.items,
    this.address,
    this.timeline,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    final itemsList = (map['items'] as List<dynamic>? ?? [])
        .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
        .toList();

    return OrderModel(
      id: id,
      userId: map['userId'] ?? '',
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      paymentMethod: map['paymentMethod'] ?? 'COD',
      orderDate: map['orderDate'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      ghnStatus: map['ghnStatus'],
      cancelReason: map['cancelReason'],
      items: itemsList,
      address: map['address'] as Map<String, dynamic>?,
      timeline: map['timeline'] as List<dynamic>?, // ← Thêm mới
    );
  }

  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'delivered':
        return 'Đã giao';
      case 'cancelled':
        return 'Đã hủy';
      case 'processing':
        return 'Đang xử lý';
      case 'shipped':
        return 'Đã giao vận';
      case 'pending':
        return 'Chờ xử lý';
      default:
        return status.toUpperCase();
    }
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'shipped':
        return const Color(0xFF7C3AED);
      case 'processing':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}

class OrderItem {
  final String productId;
  final String title;
  final String brandName;
  final String image;
  final double price;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.title,
    required this.brandName,
    required this.image,
    required this.price,
    required this.quantity,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      title: map['title'] ?? '',
      brandName: map['brandName'] ?? '',
      image: map['image'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
    );
  }
}
