import 'package:flutter/material.dart';
import 'package:kc_admin_panel/Admin/screens/admin_sidebar.dart';
import '../../controllers/media/media_controller.dart';
import 'widgets/media_empty_state.dart';
import 'widgets/media_upload_area.dart';
import 'widgets/media_grid.dart';

class MediaScreen extends StatefulWidget {
  const MediaScreen({super.key});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  final MediaController controller = MediaController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          // SIDEBAR
          AdminSidebar(currentRoute: '/admin/media'),
          // MAIN CONTENT
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔹 BREADCRUMB
                      Text(
                        controller.selectedFolder == null
                            ? "Dashboard / Media"
                            : "Dashboard / Media / ${controller.selectedFolder}",
                        style: const TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(height: 8),

                      // 🔹 HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Media",
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton.icon(
                            onPressed: controller.toggleUploadMode,
                            icon: const Icon(Icons.cloud_upload_outlined),
                            label: const Text("Upload Images"),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // 🔹 FOLDER SELECT
                      Row(
                        children: [
                          const Text("Media Folders"),
                          const SizedBox(width: 12),

                          DropdownButton<String>(
                            hint: const Text("Select Folder"),
                            value: controller.selectedFolder,
                            items: controller.folders.map((e) {
                              return DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) controller.changeFolder(value);
                            },
                          ),

                          const SizedBox(width: 16),

                          // 🔥 BADGE
                          if (controller.selectedFolder != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E88E5).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                controller.selectedFolder!,
                                style: const TextStyle(
                                  color: Color(0xFF1E88E5),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // 🔹 CONTENT
                      Expanded(
                        child: Builder(
                          builder: (_) {
                            if (controller.isUploadMode) {
                              return MediaUploadArea(controller: controller);
                            }

                            if (controller.selectedFolder == null) {
                              return const MediaEmptyState();
                            }

                            return MediaGrid(controller: controller);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
