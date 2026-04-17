import 'package:flutter/material.dart';
import 'package:kc_admin_panel/Admin/controllers/media/media_controller.dart';
import 'package:kc_admin_panel/Admin/models/uploads/media_file.dart';

class MediaPickerBottomSheet extends StatefulWidget {
  final MediaController controller;
  final Function(List<MediaFile>) onImagesSelected;

  const MediaPickerBottomSheet({
    super.key,
    required this.controller,
    required this.onImagesSelected,
  });

  // Cách gọi Bottom Sheet
  static void show(
    BuildContext context, {
    required MediaController controller,
    required Function(List<MediaFile>) onImagesSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MediaPickerBottomSheet(
        controller: controller,
        onImagesSelected: onImagesSelected,
      ),
    );
  }

  @override
  State<MediaPickerBottomSheet> createState() => _MediaPickerBottomSheetState();
}

class _MediaPickerBottomSheetState extends State<MediaPickerBottomSheet> {
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    if (widget.controller.selectedFolder == null && widget.controller.folders.isNotEmpty) {
      widget.controller.changeFolder(widget.controller.folders.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                const Text("Chọn ảnh từ Media",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text("Đóng"),
                ),
              ],
            ),
          ),
          const Divider(),

          // Folder Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: DropdownButtonFormField<String>(
              value: widget.controller.selectedFolder,
              decoration: InputDecoration(
                labelText: "Media Folder",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: widget.controller.folders
                  .map((folder) => DropdownMenuItem(value: folder, child: Text(folder)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  widget.controller.changeFolder(value);
                  setState(() {});
                }
              },
            ),
          ),

          // Grid ảnh
          Expanded(
            child: StreamBuilder<List<MediaFile>>(
              stream: widget.controller.getMediaStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final mediaList = snapshot.data!;

                if (mediaList.isEmpty) {
                  return const Center(child: Text("Không có ảnh trong thư mục này"));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemCount: mediaList.length,
                  itemBuilder: (context, index) {
                    final item = mediaList[index];
                    final isSelected = _selectedIds.contains(item.id);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedIds.remove(item.id);
                          } else {
                            _selectedIds.add(item.id);
                          }
                        });
                      },
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? Colors.blue : Colors.grey.shade300,
                                width: isSelected ? 3 : 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                item.url,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.broken_image, size: 40),
                              ),
                            ),
                          ),
                          if (isSelected)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                decoration:
                                    const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(Icons.check, color: Colors.white, size: 18),
                              ),
                            ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                                ),
                                borderRadius:
                                    const BorderRadius.vertical(bottom: Radius.circular(10)),
                              ),
                              child: Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontSize: 11),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Bottom Action
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text("${_selectedIds.length} ảnh đã chọn"),
                const Spacer(),
                ElevatedButton(
                  onPressed: _selectedIds.isEmpty
                      ? null
                      : () async {
                          // SỬA LỖI Ở ĐÂY - Không dùng .value nữa
                          final currentMediaList = await widget.controller.getMediaStream().first;

                          final selectedMedia =
                              currentMediaList.where((m) => _selectedIds.contains(m.id)).toList();

                          widget.onImagesSelected(selectedMedia);
                          Navigator.pop(context);
                        },
                  child: const Text("Xác nhận chọn"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
