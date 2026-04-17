import 'package:flutter/material.dart';
import 'package:kc_admin_panel/Admin/controllers/category/category_controller.dart';
import 'package:kc_admin_panel/Admin/controllers/media/media_controller.dart';
import 'package:kc_admin_panel/Admin/models/category/category_model.dart';
import 'package:kc_admin_panel/Admin/screens/admin_sidebar.dart';
import 'package:kc_admin_panel/Admin/screens/bottom_sheet/media_picker_bottom_sheet.dart';
import 'package:kc_admin_panel/Admin/screens/sidebar/admin_header.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final controller = CategoryController();

  void _showCreateDialog() {
    final idController = TextEditingController();
    final nameController = TextEditingController();
    final parentController = TextEditingController();

    bool isFeatured = false;
    String imageUrl = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Create Category'),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      /// ID
                      TextField(
                        controller: idController,
                        decoration: const InputDecoration(
                          labelText: 'Category ID',
                          hintText: 'vd: fashion, shoes',
                        ),
                      ),
                      const SizedBox(height: 12),

                      /// NAME
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Category Name'),
                      ),
                      const SizedBox(height: 12),

                      /// IMAGE PICKER (GIỐNG BRAND)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text("Ảnh danh mục",
                                  style: TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(width: 10),
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
                              ElevatedButton.icon(
                                onPressed: () {
                                  MediaPickerBottomSheet.show(
                                    context,
                                    controller: MediaController(),
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

                      /// PARENT
                      TextField(
                        controller: parentController,
                        decoration: const InputDecoration(labelText: 'Parent Category ID'),
                      ),
                    ],
                  ),
                ),
              ),
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
                      await controller.createCategory(
                        CategoryModel(
                          id: id,
                          name: nameController.text.trim(),
                          image: imageUrl,
                          isFeatured: isFeatured,
                          parentId: parentController.text.trim(),
                        ),
                      );

                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Category created')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ================= EDIT DIALOG =================
  void _showEditDialog(CategoryModel category) {
    final nameController = TextEditingController(text: category.name);
    final imageController = TextEditingController(text: category.image);
    final parentController = TextEditingController(text: category.parentId);

    bool isFeatured = category.isFeatured;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Edit Category'),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Category Name'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: imageController,
                        decoration: const InputDecoration(labelText: 'Image URL'),
                      ),
                      const SizedBox(height: 16),

                      /// ✅ FIX SWITCH
                      SwitchListTile(
                        title: const Text('Is Featured'),
                        value: isFeatured,
                        onChanged: (value) {
                          setStateDialog(() {
                            isFeatured = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),
                      TextField(
                        controller: parentController,
                        decoration: const InputDecoration(labelText: 'Parent Category ID'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await controller.updateCategory(
                      CategoryModel(
                        id: category.id,
                        name: nameController.text.trim(),
                        image: imageController.text.trim(),
                        isFeatured: isFeatured,
                        parentId: parentController.text.trim(),
                      ),
                    );

                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Category updated successfully')),
                      );
                    }
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

  void _confirmDeleteCategory(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Xóa danh mục?"),
        content: const Text("Hành động này không thể hoàn tác."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Xóa",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await controller.deleteCategory(id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa danh mục')),
        );
      }
    }
  }

  // ================= DELETE =================
  void _deleteCategory(String id) async {
    await controller.deleteCategory(id);
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          const AdminSidebar(currentRoute: '/admin/categories'),
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
                            const Text(
                              'Danh Mục',
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                            ElevatedButton.icon(
                              onPressed: _showCreateDialog,
                              icon: const Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Tạo danh mục",
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
                          child: StreamBuilder<List<CategoryModel>>(
                            stream: controller.getCategories(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              final categories = snapshot.data!;

                              if (categories.isEmpty) {
                                return const Center(child: Text('No categories found'));
                              }

                              return Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: Color(0xFFE0E0E0)),
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
                                              columnSpacing: 80,
                                              headingRowHeight: 56,
                                              dataRowHeight: 72,
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
                                                horizontalInside:
                                                    const BorderSide(color: Color(0xFFEDEDED)),
                                              ),
                                              columns: const [
                                                DataColumn(
                                                    label: Text('Category',
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.bold))),
                                                DataColumn(
                                                    label: Text('Parent',
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
                                              rows: categories.map((cat) {
                                                return DataRow(cells: [
                                                  /// CATEGORY
                                                  DataCell(Row(
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius: BorderRadius.circular(8),
                                                        child: Image.network(
                                                          cat.image,
                                                          width: 48,
                                                          height: 48,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (_, __, ___) => Container(
                                                            width: 48,
                                                            height: 48,
                                                            color: Colors.grey[100],
                                                            child: const Icon(
                                                                Icons.image_not_supported),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Text(cat.name),
                                                    ],
                                                  )),

                                                  /// PARENT
                                                  DataCell(Text(cat.parentId.isNotEmpty
                                                      ? cat.parentId
                                                      : '—')),

                                                  /// FEATURED
                                                  DataCell(
                                                    Switch(
                                                      value: cat.isFeatured,
                                                      onChanged: (value) {
                                                        controller.updateCategory(
                                                          CategoryModel(
                                                            id: cat.id,
                                                            name: cat.name,
                                                            image: cat.image,
                                                            isFeatured: value,
                                                            parentId: cat.parentId,
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
                                                        onPressed: () => _showEditDialog(cat),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(Icons.delete,
                                                            color: Colors.red),
                                                        onPressed: () =>
                                                            _confirmDeleteCategory(cat.id),
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
