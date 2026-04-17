import 'package:flutter/material.dart';
import 'package:kc_admin_panel/Admin/controllers/banner/banner_controller.dart';
import 'package:kc_admin_panel/Admin/controllers/media/media_controller.dart';
import 'package:kc_admin_panel/Admin/models/banner/banner_models.dart';
import 'package:kc_admin_panel/Admin/screens/admin_sidebar.dart';
import 'package:kc_admin_panel/Admin/screens/bottom_sheet/media_picker_bottom_sheet.dart';
import 'package:kc_admin_panel/Admin/screens/sidebar/admin_header.dart';

class BannersScreen extends StatefulWidget {
  const BannersScreen({super.key});

  @override
  State<BannersScreen> createState() => _BannersScreenState();
}

class _BannersScreenState extends State<BannersScreen> {
  final controller = BannerController();
  final mediaController = MediaController();

  // ================= DELETE CONFIRM =================
  void _confirmDelete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Xóa Banner?"),
        content: const Text("Hành động này không thể hoàn tác."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Hủy")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await controller.deleteBanner(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã xóa banner")),
        );
      }
    }
  }

  // ================= CREATE DIALOG =================
  // ================= CREATE DIALOG (ID TỰ ĐỘNG) =================
  void _showCreateDialog() {
    String imageUrl = '';
    String targetScreen = '/store'; // Default theo dữ liệu mẫu của bạn
    bool active = true;

    final List<String> targetOptions = [
      '/on-boarding',
      '/store',
      '/search',
      '/home',
      '/category',
      '/brand',
      '/product',
      '/cart',
      '/profile',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Tạo Banner Mới'),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Image Picker
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Ảnh Banner", style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                width: 100,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: imageUrl.isEmpty
                                    ? const Icon(Icons.image, size: 40, color: Colors.grey)
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(imageUrl, fit: BoxFit.cover),
                                      ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  MediaPickerBottomSheet.show(
                                    context,
                                    controller: mediaController,
                                    onImagesSelected: (images) {
                                      if (images.isNotEmpty) {
                                        setStateDialog(() => imageUrl = images.first.url);
                                      }
                                    },
                                  );
                                },
                                icon: const Icon(Icons.photo_library),
                                label: Text(imageUrl.isEmpty ? "Chọn ảnh" : "Đổi ảnh"),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Target Screen
                      DropdownButtonFormField<String>(
                        value: targetScreen,
                        decoration: const InputDecoration(labelText: 'Target Screen'),
                        items: targetOptions
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) setStateDialog(() => targetScreen = value);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Active
                      SwitchListTile(
                        title: const Text('Active'),
                        value: active,
                        onChanged: (value) => setStateDialog(() => active = value),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                ElevatedButton(
                  onPressed: () async {
                    if (imageUrl.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Vui lòng chọn ảnh banner")),
                      );
                      return;
                    }

                    try {
                      await controller.createBanner(
                        imageUrl: imageUrl,
                        targetScreen: targetScreen,
                        active: active,
                      );

                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tạo banner thành công')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi: ${e.toString()}')),
                      );
                    }
                  },
                  child: const Text('Tạo Banner'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ================= EDIT DIALOG =================
  void _showEditDialog(BannerModel banner) {
    String imageUrl = banner.imageUrl;
    String targetScreen = banner.targetScreen;
    bool active = banner.active;

    final List<String> targetOptions = [
      '/search',
      '/home',
      '/category',
      '/brand',
      '/product',
      '/cart',
      '/profile'
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Chỉnh sửa Banner'),
              content: SizedBox(
                width: 520,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: imageUrl.isEmpty
                              ? const Icon(Icons.image, size: 40)
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(imageUrl, fit: BoxFit.cover),
                                ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            MediaPickerBottomSheet.show(
                              context,
                              controller: mediaController,
                              onImagesSelected: (images) {
                                if (images.isNotEmpty) {
                                  setStateDialog(() => imageUrl = images.first.url);
                                }
                              },
                            );
                          },
                          icon: const Icon(Icons.photo_library),
                          label: const Text("Chọn ảnh"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Target Screen
                    DropdownButtonFormField<String>(
                      value: targetScreen,
                      decoration: const InputDecoration(labelText: 'Target Screen'),
                      items: targetOptions
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setStateDialog(() => targetScreen = value);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Active
                    SwitchListTile(
                      title: const Text('Active'),
                      value: active,
                      onChanged: (value) => setStateDialog(() => active = value),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                ElevatedButton(
                  onPressed: () async {
                    await controller.updateBanner(
                      BannerModel(
                        id: banner.id,
                        imageUrl: imageUrl,
                        targetScreen: targetScreen,
                        active: active,
                      ),
                    );
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          const AdminSidebar(currentRoute: '/admin/banners'),
          Expanded(
            child: Column(
              children: [
                const AdminHeader(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Banners',
                                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                            ElevatedButton.icon(
                              onPressed: _showCreateDialog,
                              icon: const Icon(Icons.add, color: Colors.white),
                              label:
                                  const Text("Tạo Banner", style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                backgroundColor: Colors.green.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Table
                        Expanded(
                          child: StreamBuilder<List<BannerModel>>(
                            stream: controller.getBanners(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              final banners = snapshot.data!;

                              return Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      return SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: ConstrainedBox(
                                          constraints:
                                              BoxConstraints(minWidth: constraints.maxWidth),
                                          child: DataTable(
                                            headingRowHeight: 56,
                                            dataRowHeight: 110, // cao hơn vì có ảnh banner
                                            horizontalMargin: 24,
                                            columnSpacing: 60,
                                            headingRowColor:
                                                WidgetStateProperty.all(const Color(0xFFF8F9FA)),
                                            dataRowColor:
                                                WidgetStateProperty.resolveWith<Color?>((states) {
                                              if (states.contains(WidgetState.hovered)) {
                                                return const Color(0xFFF5F7FA);
                                              }
                                              return Colors.white;
                                            }),
                                            border: TableBorder(
                                              horizontalInside: const BorderSide(
                                                  color: Color(0xFFEDEDED), width: 1),
                                              verticalInside: BorderSide.none,
                                              top: const BorderSide(
                                                  color: Color(0xFFE0E0E0), width: 1),
                                              bottom: const BorderSide(
                                                  color: Color(0xFFE0E0E0), width: 1),
                                            ),
                                            columns: const [
                                              DataColumn(
                                                  label: Text('Banner',
                                                      style:
                                                          TextStyle(fontWeight: FontWeight.bold))),
                                              DataColumn(
                                                  label: Text('Target Screen',
                                                      style:
                                                          TextStyle(fontWeight: FontWeight.bold))),
                                              DataColumn(
                                                  label: Text('Active',
                                                      style:
                                                          TextStyle(fontWeight: FontWeight.bold))),
                                              DataColumn(
                                                  label: Text('Action',
                                                      style:
                                                          TextStyle(fontWeight: FontWeight.bold))),
                                            ],
                                            rows: banners.map((banner) {
                                              return DataRow(cells: [
                                                // Banner Image + ID
                                                DataCell(
                                                  Row(
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius: BorderRadius.circular(10),
                                                        child: Image.network(
                                                          banner.imageUrl,
                                                          width: 140,
                                                          height: 80,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (_, __, ___) => Container(
                                                            width: 140,
                                                            height: 80,
                                                            color: Colors.grey[200],
                                                            child: const Icon(Icons.broken_image,
                                                                color: Colors.grey),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Text(
                                                          banner.id,
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(
                                                              fontWeight: FontWeight.w500),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                // Target Screen
                                                DataCell(Text(banner.targetScreen)),

                                                // Active Switch
                                                DataCell(
                                                  Switch(
                                                    value: banner.active,
                                                    onChanged: (value) {
                                                      controller.updateBanner(
                                                        BannerModel(
                                                          id: banner.id,
                                                          imageUrl: banner.imageUrl,
                                                          targetScreen: banner.targetScreen,
                                                          active: value,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),

                                                // Actions
                                                DataCell(
                                                  Row(
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(Icons.edit,
                                                            color: Colors.blue),
                                                        onPressed: () => _showEditDialog(banner),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(Icons.delete,
                                                            color: Colors.red),
                                                        onPressed: () => _confirmDelete(banner.id),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ]);
                                            }).toList(),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
