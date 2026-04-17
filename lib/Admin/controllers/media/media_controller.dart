import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:kc_admin_panel/data/repositories/storage/storage_repository.dart';
import '../../models/uploads/media_file.dart';

class MediaController with ChangeNotifier {
  final StorageRepository _repository = StorageRepository();

  String? selectedFolder;
  bool isUploading = false;
  bool isUploadMode = false;

  List<PlatformFile> selectedFiles = [];

  final List<String> folders = ['Banners', 'Brands', 'Categories', 'Products', 'Users', 'Reviews'];

  void changeFolder(String folder) {
    selectedFolder = folder;
    notifyListeners();
  }

  void toggleUploadMode() {
    isUploadMode = !isUploadMode;
    notifyListeners();
  }

  Future<void> pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );

    if (result != null) {
      selectedFiles.addAll(result.files);
      notifyListeners();
    }
  }

  Future<void> uploadImages() async {
    if (selectedFiles.isEmpty || selectedFolder == null) return;

    isUploading = true;
    notifyListeners();

    for (var file in selectedFiles) {
      await _repository.uploadFilePlatform(file, selectedFolder!);
    }

    selectedFiles.clear();
    isUploading = false;
    isUploadMode = false;
    notifyListeners();
  }

  void removeAt(int index) {
    selectedFiles.removeAt(index);
    notifyListeners();
  }

  void removeAll() {
    selectedFiles.clear();
    notifyListeners();
  }

  Stream<List<MediaFile>> getMediaStream() {
    if (selectedFolder == null) return const Stream.empty();
    return _repository.getMediaByFolder(selectedFolder!);
  }

  // ==================== HÀM XÓA ẢNH MỚI THÊM ====================
  Future<void> deleteMedia(MediaFile mediaFile) async {
    if (selectedFolder == null) return;

    try {
      await _repository.deleteMedia(mediaFile, selectedFolder!);
      // Không cần notifyListeners() vì StreamBuilder sẽ tự cập nhật
    } catch (e) {
      rethrow; // Để UI bắt lỗi và hiển thị thông báo
    }
  }
}
