import 'package:flutter/material.dart';
import 'package:kc_admin_panel/Admin/controllers/brand/brand_controller.dart';
import 'package:kc_admin_panel/Admin/controllers/media/media_controller.dart' show MediaController;
import 'package:kc_admin_panel/Admin/models/brand/brand_model.dart';
import 'package:kc_admin_panel/Admin/screens/admin_sidebar.dart';
import 'package:kc_admin_panel/Admin/screens/bottom_sheet/media_picker_bottom_sheet.dart';
import 'package:kc_admin_panel/Admin/screens/sidebar/admin_header.dart';

class BrandsScreen extends StatefulWidget {
  const BrandsScreen({super.key});

  @override
  State<BrandsScreen> createState() => _BrandsScreenState();
}

class _BrandsScreenState extends State<BrandsScreen> {
  final controller = BrandController();
  final mediaController = MediaController();
  String imageUrl = '';

  // ================= DELETE CONFIRM =================
  void _confirmDelete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xóa thương hiệu?"),
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
      await controller.deleteBrand(id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã xóa thương hiệu")),
        );
      }
    }
  }

  void _showCreateDialog() {
    final idController = TextEditingController();
    final nameController = TextEditingController();
    final countController = TextEditingController(text: "0");

    bool isFeatured = false;
    String imageUrl = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Tạo Thương Hiệu'),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// ✅ ID
                      TextField(
                        controller: idController,
                        decoration: const InputDecoration(
                          labelText: 'Brand ID',
                          hintText: 'Ví dụ: 1,2,nike, adidas',
                        ),
                      ),
                      const SizedBox(height: 12),

                      /// NAME
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Brand Name'),
                      ),
                      const SizedBox(height: 12),

                      /// ✅ IMAGE PICKER (NEW UI)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text("Ảnh thương hiệu",
                                  style: TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(width: 10),

                              /// ❌ XOÁ ẢNH
                              if (imageUrl.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    setStateDialog(() {
                                      imageUrl = '';
                                    });
                                  },
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.close, size: 14, color: Colors.red),
                                        SizedBox(width: 4),
                                        Text("Xoá",
                                            style: TextStyle(color: Colors.red, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              /// PREVIEW
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: imageUrl.isEmpty
                                    ? const Icon(Icons.image, color: Colors.grey)
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(imageUrl, fit: BoxFit.cover),
                                      ),
                              ),

                              const SizedBox(width: 12),

                              /// BUTTON
                              ElevatedButton.icon(
                                onPressed: () {
                                  MediaPickerBottomSheet.show(
                                    context,
                                    controller: mediaController,
                                    onImagesSelected: (images) {
                                      if (images.isNotEmpty) {
                                        setStateDialog(() {
                                          imageUrl = images.first.url;
                                        });
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

                      const SizedBox(height: 12),

                      /// FEATURED
                      SwitchListTile(
                        title: const Text('Is Featured'),
                        value: isFeatured,
                        onChanged: (value) {
                          setStateDialog(() => isFeatured = value);
                        },
                      ),

                      /// COUNT
                      TextField(
                        controller: countController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Products Count'),
                      ),
                    ],
                  ),
                ),
              ),

              /// ACTIONS
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final id = idController.text.trim().toLowerCase();

                    if (id.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Vui lòng nhập ID")),
                      );
                      return;
                    }

                    if (imageUrl.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Vui lòng chọn ảnh")),
                      );
                      return;
                    }

                    try {
                      await controller.createBrand(
                        BrandModel(
                          id: id,
                          name: nameController.text.trim(),
                          image: imageUrl,
                          isFeatured: isFeatured,
                          productsCount: int.tryParse(countController.text) ?? 0,
                        ),
                      );

                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tạo thương hiệu')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  },
                  child: const Text('Tạo'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ================= EDIT =================
  void _showEditDialog(BrandModel brand) {
    final nameController = TextEditingController(text: brand.name);
    final countController = TextEditingController(text: brand.productsCount.toString());

    bool isFeatured = brand.isFeatured;
    String imageUrl = brand.image; // ✅ local

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Edit Brand'),
              content: SizedBox(
                width: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: nameController),
                    const SizedBox(height: 12),

                    /// ✅ MEDIA PICKER
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: imageUrl.isEmpty
                              ? const Icon(Icons.image)
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(imageUrl, fit: BoxFit.cover),
                                ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            MediaPickerBottomSheet.show(
                              context,
                              controller: mediaController,
                              onImagesSelected: (images) {
                                if (images.isNotEmpty) {
                                  setStateDialog(() {
                                    imageUrl = images.first.url;
                                  });
                                }
                              },
                            );
                          },
                          child: const Text("Chọn ảnh"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    SwitchListTile(
                      title: const Text('Is Featured'),
                      value: isFeatured,
                      onChanged: (value) {
                        setStateDialog(() => isFeatured = value);
                      },
                    ),

                    TextField(
                      controller: countController,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    await controller.updateBrand(
                      BrandModel(
                        id: brand.id,
                        name: nameController.text.trim(),
                        image: imageUrl,
                        isFeatured: isFeatured,
                        productsCount: int.tryParse(countController.text) ?? 0,
                      ),
                    );

                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          const AdminSidebar(currentRoute: '/admin/brands'),
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
                        /// HEADER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Thương Hiệu',
                                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                            ElevatedButton.icon(
                              onPressed: _showCreateDialog,
                              icon: const Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Tạo thương hiệu",
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                backgroundColor: Colors.green.shade600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                       

                        /// TABLE
                        Expanded(
                          child: StreamBuilder<List<BrandModel>>(
                            stream: controller.getBrands(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              final brands = snapshot.data!;

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
                                          child: SingleChildScrollView(
                                            child: DataTable(
                                              headingRowHeight: 56,
                                              dataRowHeight: 72,
                                              horizontalMargin: 24,
                                              columnSpacing: 80,

                                              /// ✅ Header màu xám nhạt
                                              headingRowColor: WidgetStateProperty.all(
                                                const Color(0xFFF8F9FA),
                                              ),

                                              /// ✅ Hover row
                                              dataRowColor:
                                                  WidgetStateProperty.resolveWith<Color?>((states) {
                                                if (states.contains(WidgetState.hovered)) {
                                                  return const Color(0xFFF5F7FA);
                                                }
                                                return Colors.white;
                                              }),

                                              /// ✅ Border giống Categories
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
                                                    label: Text('Brand',
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.bold))),
                                                DataColumn(
                                                    label: Text('Products',
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.bold))),
                                                DataColumn(
                                                    label: Text('Featured',
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.bold))),
                                                DataColumn(
                                                    label: Text('Action',
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.bold))),
                                              ],

                                              rows: brands.map((brand) {
                                                return DataRow(cells: [
                                                  /// BRAND
                                                  DataCell(Row(
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius: BorderRadius.circular(8),
                                                        child: Image.network(
                                                          brand.image,
                                                          width: 48,
                                                          height: 48,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (_, __, ___) => Container(
                                                            width: 48,
                                                            height: 48,
                                                            color: Colors.grey[100],
                                                            child: const Icon(
                                                              Icons.image_not_supported,
                                                              size: 20,
                                                              color: Colors.grey,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Text(
                                                          brand.name,
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  )),

                                                  /// PRODUCTS COUNT
                                                  DataCell(Text(brand.productsCount.toString())),

                                                  /// FEATURED SWITCH
                                                  DataCell(
                                                    Switch(
                                                      value: brand.isFeatured,
                                                      onChanged: (value) {
                                                        controller.updateBrand(
                                                          BrandModel(
                                                            id: brand.id,
                                                            name: brand.name,
                                                            image: brand.image,
                                                            isFeatured: value,
                                                            productsCount: brand.productsCount,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),

                                                  /// ACTION
                                                  DataCell(Row(
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(Icons.edit,
                                                            color: Colors.blue),
                                                        onPressed: () => _showEditDialog(brand),
                                                        tooltip: "Tuỳ chọn",
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(Icons.delete,
                                                            color: Colors.red),
                                                        onPressed: () => _confirmDelete(brand.id),
                                                        tooltip: "Xóa",
                                                      ),
                                                    ],
                                                  )),
                                                ]);
                                              }).toList(),
                                            ),
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
