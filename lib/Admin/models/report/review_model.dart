import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final String userAvatar;
  final String comment;
  final double rating;
  final List<String> images;
  final Timestamp? createdAt;
  final Map<String, dynamic>? variation;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.comment,
    required this.rating,
    required this.images,
    this.createdAt,
    this.variation,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) {
    return ReviewModel(
      id: id,
      productId: map['productId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userAvatar: map['userAvatar'] ?? '',
      comment: map['comment'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      images: List<String>.from(map['images'] ?? []),
      createdAt: map['createdAt'],
      variation: map['variation'] as Map<String, dynamic>?,
    );
  }
}