import 'package:flutter/material.dart';
import 'package:kc_admin_panel/Admin/controllers/media/media_controller.dart';

class MediaUploadArea extends StatelessWidget {
  final MediaController controller;

  const MediaUploadArea({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            // PREVIEW
            if (controller.selectedFiles.isNotEmpty)
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.selectedFiles.length,
                  itemBuilder: (context, index) {
                    final file = controller.selectedFiles[index];

                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: MemoryImage(file.bytes!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: () => controller.removeAt(index),
                            child: const CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.black54,
                              child: Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

            const SizedBox(height: 20),

            // BOX
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_upload_outlined, size: 80, color: Color(0xFF1E88E5)),
                      const SizedBox(height: 10),
                      const Text("Drag & Drop Images here"),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: controller.pickImages,
                        child: const Text("Select Images"),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // CONTROL
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  DropdownButton<String>(
                    hint: const Text("Select Folder"),
                    value: controller.selectedFolder,
                    items: controller.folders
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) controller.changeFolder(value);
                    },
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: controller.removeAll,
                    child: const Text("Remove All"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: controller.selectedFolder == null ? null : controller.uploadImages,
                    child: controller.isUploading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Upload"),
                  ),
                ],
              ),
            ),
          ],
        ),

        // LOADING
        if (controller.isUploading)
          Container(
            color: Colors.black38,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
