import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:kc_admin_panel/Admin/models/uploads/media_file.dart';
import 'package:uuid/uuid.dart';

class StorageRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  Future<MediaFile?> uploadFilePlatform(PlatformFile file, String folder) async {
    try {
      final fileName = '${_uuid.v4()}_${file.name}';
      final ref = _storage.ref('$folder/$fileName');

      UploadTask uploadTask;

      if (kIsWeb) {
        uploadTask = ref.putData(file.bytes!);
      } else {
        final fileData = File(file.path!);
        uploadTask = ref.putFile(fileData);
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      final mediaId = _uuid.v4();

      final mediaData = {
        'name': fileName,
        'url': downloadUrl,
        'folder': folder,
        'type': file.extension,
        'uploadedAt': FieldValue.serverTimestamp(),
      };

      // Lưu vào collection tương ứng
      await _firestore.collection(folder).doc(mediaId).set(mediaData);

      return MediaFile.fromMap(mediaData, mediaId);
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  Stream<List<MediaFile>> getMediaByFolder(String folder) {
    return _firestore.collection(folder).orderBy('uploadedAt', descending: true).snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => MediaFile.fromMap(doc.data(), doc.id)).toList());
  }

  // ==================== HÀM XÓA ẢNH ====================
  Future<void> deleteMedia(MediaFile mediaFile, String folder) async {
    try {
      // 1. Xóa file trong Firebase Storage (dùng refFromURL an toàn nhất)
      final storageRef = _storage.refFromURL(mediaFile.url);
      await storageRef.delete();

      // 2. Xóa document trong Firestore
      await _firestore
          .collection(folder) // collection = folder hiện tại
          .doc(mediaFile.id) // id của document
          .delete();

      print('Deleted media: ${mediaFile.name}');
    } catch (e) {
      print('Delete error: $e');
      rethrow;
    }
  }
}
