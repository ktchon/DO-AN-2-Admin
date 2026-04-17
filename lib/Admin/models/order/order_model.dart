import 'dart:ui';

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
  final Map<String, dynamic>? address; // Address map từ order

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
      default:
        return status.toUpperCase();
    }
  }

  Color get statusColor {
    if (status.toLowerCase() == 'delivered') return Colors.green;
    if (status.toLowerCase() == 'cancelled') return Colors.red;
    return Colors.orange;
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
