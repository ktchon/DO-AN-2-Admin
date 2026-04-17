import 'package:cloud_firestore/cloud_firestore.dart';

class BannerModel {
  final String id;
  final String imageUrl; // Dart dùng camelCase
  final String targetScreen;
  final bool active;
  final Timestamp? createdAt;
  final Timestamp? updatedAt; // Tùy chọn

  BannerModel({
    required this.id,
    required this.imageUrl,
    required this.targetScreen,
    required this.active,
    this.createdAt,
    this.updatedAt,
  });

  // fromMap: Đọc từ Firebase 
  factory BannerModel.fromMap(Map<String, dynamic> map, String id) {
    return BannerModel(
      id: id,
      imageUrl: map['ImageUrl'] ?? '',
      targetScreen: map['TargetScreen'] ?? '/on-boarding',
      active: map['Active'] ?? false,
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  // toMap: Chỉ dùng khi cần, nhưng ở repo ta set thủ công để rõ ràng hơn
  Map<String, dynamic> toMap() {
    return {
      'ImageUrl': imageUrl,
      'TargetScreen': targetScreen,
      'Active': active,
    };
  }
}
