import 'package:cloud_firestore/cloud_firestore.dart';

class MediaFile {
  final String id;
  final String name;
  final String url;
  final String folder;
  final String? type;
  final DateTime uploadedAt;

  MediaFile({
    required this.id,
    required this.name,
    required this.url,
    required this.folder,
    this.type,
    required this.uploadedAt,
  });

  factory MediaFile.fromMap(Map<String, dynamic> map, String id) {
    return MediaFile(
      id: id,
      name: map['name'] ?? '',
      url: map['url'] ?? '',
      folder: map['folder'] ?? '',
      type: map['type'],
      uploadedAt: (map['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}