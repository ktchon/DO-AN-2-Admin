import 'package:cloud_firestore/cloud_firestore.dart';

class CouponModel {
  final String id;
  final String code;
  final double value;
  final String type; // percentage | fixed
  final double minOrder;
  final double maxDiscount;
  final int usageLimit;
  final int usedCount;
  final bool isActive;
  final DateTime expiryDate;

  CouponModel({
    required this.id,
    required this.code,
    required this.value,
    required this.type,
    required this.minOrder,
    required this.maxDiscount,
    required this.usageLimit,
    required this.usedCount,
    required this.isActive,
    required this.expiryDate,
  });

  factory CouponModel.fromFirestore(doc) {
    final data = doc.data();

    return CouponModel(
      id: doc.id,
      code: data['code'] ?? '',
      value: (data['value'] ?? 0).toDouble(),
      type: data['type'] ?? 'percentage',
      minOrder: (data['minOrder'] ?? 0).toDouble(),
      maxDiscount: (data['maxDiscount'] ?? 0).toDouble(),
      usageLimit: data['usageLimit'] ?? 0,
      usedCount: data['usedCount'] ?? 0,
      isActive: data['isActive'] ?? false,
      expiryDate: (data['expiryDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'value': value,
      'type': type,
      'minOrder': minOrder,
      'maxDiscount': maxDiscount,
      'usageLimit': usageLimit,
      'usedCount': usedCount,
      'isActive': isActive,
      'expiryDate': expiryDate,
    };
  }
}