import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kc_admin_panel/Admin/controllers/media/media_controller.dart';
import 'package:kc_admin_panel/Admin/models/uploads/media_file.dart';

class MediaPreviewDialog extends StatelessWidget {
  final MediaFile file;
  final MediaController controller;

  const MediaPreviewDialog({
    super.key,
    required this.file,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 680,
        // Loại bỏ constraints maxHeight cứng để dialog tự co giãn
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          // ← Thêm cái này để tránh overflow
          child: Column(
            mainAxisSize: MainAxisSize.min, // Giữ nguyên min
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 8),
                child: Row(
                  children: [
                    const Text(
                      "Media Preview",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Image Preview
              Padding(
                padding: const EdgeInsets.all(24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 420),
                    child: Image.network(
                      file.url,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),

              // Information
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow("Tên file", file.name),
                    const SizedBox(height: 12),
                    _infoRow("URL", file.url, isCopyable: true, context: context),
                  ],
                ),
              ),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    StatefulBuilder(
                      builder: (context, setState) {
                        bool isDeleting = false;

                        return TextButton.icon(
                          onPressed: isDeleting
                              ? null
                              : () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text("Xác nhận xóa"),
                                      content: const Text(
                                          "Bạn có chắc muốn xóa ảnh này?\nHành động này không thể hoàn tác."),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, false),
                                          child: const Text("Hủy"),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, true),
                                          child: const Text("Xóa",
                                              style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm != true) return;

                                  setState(() => isDeleting = true);

                                  try {
                                    await controller.deleteMedia(file);
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Đã xóa ảnh thành công"),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Xóa thất bại: $e"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                          icon: isDeleting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2, color: Colors.red))
                              : const Icon(Icons.delete_outline, color: Colors.red),
                          label: Text(
                            isDeleting ? "Đang xóa..." : "Xóa ảnh",
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      },
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Đóng"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isCopyable = false, BuildContext? context}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 80, child: Text(label, style: TextStyle(color: Colors.grey.shade600))),
        Expanded(child: SelectableText(value, style: const TextStyle(fontSize: 14))),
        if (isCopyable && context != null)
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text("Đã sao chép URL")));
            },
            icon: const Icon(Icons.copy, size: 18),
            label: const Text("Copy"),
          ),
      ],
    );
  }
}
