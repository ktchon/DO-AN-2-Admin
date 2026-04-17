import 'package:flutter/material.dart';
import 'package:kc_admin_panel/Admin/controllers/media/media_controller.dart';
import 'package:kc_admin_panel/Admin/models/uploads/media_file.dart';
import 'package:kc_admin_panel/Admin/screens/media/widgets/media_preview_dialog.dart';

class MediaGrid extends StatelessWidget {
  final MediaController controller;

  const MediaGrid({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MediaFile>>(
      stream: controller.getMediaStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final mediaList = snapshot.data!;

        if (mediaList.isEmpty) {
          return const Center(
            child: Text(
              "No images found",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: mediaList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85, // Giảm chiều cao một chút để ảnh nhỏ hơn
          ),
          itemBuilder: (context, index) {
            final item = mediaList[index];

            return _buildMediaCard(context, item);
          },
        );
      },
    );
  }

  Widget _buildMediaCard(BuildContext context, MediaFile item) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => MediaPreviewDialog(
            file: item,
            controller: controller,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  children: [
                    Image.network(
                      item.url,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                      ),
                    ),
                    // Gradient overlay ở dưới ảnh để tên dễ đọc hơn
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Name Section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
