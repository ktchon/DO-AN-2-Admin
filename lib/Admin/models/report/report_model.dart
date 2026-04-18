import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String reviewId;
  final String userId;        
  final String reason;
  final Timestamp? createdAt;

  ReportModel({
    required this.id,
    required this.reviewId,
    required this.userId,
    required this.reason,
    this.createdAt,
  });

  factory ReportModel.fromMap(Map<String, dynamic> map, String id) {
    return ReportModel(
      id: id,
      reviewId: map['reviewId'] ?? '',
      userId: map['userId'] ?? '',
      reason: map['reason'] ?? '',
      createdAt: map['createdAt'],
    );
  }
}