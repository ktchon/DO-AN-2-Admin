import 'package:flutter/material.dart';
import 'package:kc_admin_panel/Admin/controllers/media/media_controller.dart';
import 'package:kc_admin_panel/Admin/controllers/product/product_controller.dart';
import 'package:kc_admin_panel/Admin/models/products/attribute_model.dart';
import 'package:kc_admin_panel/Admin/models/products/brand_model.dart';
import 'package:kc_admin_panel/Admin/models/products/product_model.dart';
import 'package:kc_admin_panel/Admin/screens/admin_sidebar.dart';
import 'package:kc_admin_panel/Admin/screens/bottom_sheet/media_picker_bottom_sheet.dart';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({super.key, this.productToEdit});
  final ProductModel? productToEdit;

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final ProductController productController = ProductController();
  final MediaController mediaController = MediaController();
  @override
  void initState() {
    super.initState();

    if (widget.productToEdit != null) {
      final p = widget.productToEdit!;
      idController.text = p.id;
      titleController.text = p.title;
      descriptionController.text = p.description;
      skuController.text = p.sku;
      priceController.text = p.price.toString();
      salePriceController.text = p.salePrice.toString();
      stockController.text = p.stock.toString();
      thumbnailUrl = p.thumbnail;
      additionalImages = List.from(p.images);
      isFeatured = p.isFeatured;
      productType = p.productType;
      brand = p.brand?.name ?? "Nike";
    }
  }

  // Form Controllers
  final idController = TextEditingController(); 
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final skuController = TextEditingController();
  final priceController = TextEditingController();
  final salePriceController = TextEditingController();
  final stockController = TextEditingController();

  String brand = "Nike";
  String productType = "ProductType.single"; // single hoặc variable
  String? thumbnailUrl;
  List<String> additionalImages = [];
  bool isFeatured = false;

  final List<String> brands = ["Nike", "ZARA", "Adidas", "Puma", "H&M"];
  // Size và Color cho sản phẩm
  final List<String> availableSizes = [
    'S',
    'M',
    'L',
    'XL',
    'XXL',
  ];
  final List<String> availableColors = [
    'Black',
    'White',
    'Green',
    'Red',
  ];

  List<String> selectedSizes = [];
  List<String> selectedColors = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          const AdminSidebar(currentRoute: '/admin/products'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back)),
                      const Text("Create Product",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 30),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ==================== LEFT FORM ====================
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            // Product ID (Nhập thủ công)
                            _buildCard("Product ID (Nhập thủ công)", [
                              TextField(
                                controller: idController,
                                decoration: const InputDecoration(
                                  labelText: "Product ID",
                                  hintText: "Ví dụ: 001, AT001, P001",
                                ),
                              ),
                            ]),

                            const SizedBox(height: 20),

                            // Basic Information
                            _buildCard("Basic Information", [
                              TextField(
                                  controller: titleController,
                                  decoration: const InputDecoration(labelText: "Product Title")),
                              const SizedBox(height: 16),
                              TextField(
                                controller: descriptionController,
                                maxLines: 3,
                                decoration: const InputDecoration(labelText: "Product Description"),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                  controller: skuController,
                                  decoration: const InputDecoration(labelText: "SKU")),
                            ]),

                            const SizedBox(height: 20),

                            // Product Type
                            _buildCard("Product Type", [
                              Row(
                                children: [
                                  Expanded(
                                    child: RadioListTile<String>(
                                      title: const Text("Single"),
                                      value: "ProductType.single",
                                      groupValue: productType,
                                      onChanged: (value) => setState(() => productType = value!),
                                    ),
                                  ),
                                  Expanded(
                                    child: RadioListTile<String>(
                                      title: const Text("Variable"),
                                      value: "ProductType.variable",
                                      groupValue: productType,
                                      onChanged: (value) => setState(() => productType = value!),
                                    ),
                                  ),
                                ],
                              ),
                            ]),

                            const SizedBox(height: 20),

                            // Stock & Pricing
                            _buildCard("Stock & Pricing", [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: stockController,
                                      decoration: const InputDecoration(labelText: "Stock"),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextField(
                                      controller: priceController,
                                      decoration: const InputDecoration(labelText: "Price"),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: salePriceController,
                                decoration:
                                    const InputDecoration(labelText: "Sale Price (Discounted)"),
                                keyboardType: TextInputType.number,
                              ),
                            ]),
                          ],
                        ),
                      ),

                      const SizedBox(width: 30),

                      // ==================== RIGHT - IMAGES ====================
                      Expanded(
                        child: Column(
                          children: [
                            // Thumbnail
                            _buildCard("Product Thumbnail", [
                              GestureDetector(
                                onTap: _selectThumbnail,
                                child: Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: thumbnailUrl == null
                                      ? const Center(
                                          child: Icon(Icons.add_photo_alternate,
                                              size: 60, color: Colors.grey))
                                      : ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(thumbnailUrl!, fit: BoxFit.cover),
                                        ),
                                ),
                              ),
                            ]),

                            const SizedBox(height: 24),

                            // Additional Images
                            _buildCard("Additional Images", [
                              GestureDetector(
                                onTap: _selectAdditionalImages,
                                child: Container(
                                  height: 140,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey.shade300, style: BorderStyle.solid),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_photo_alternate_outlined, size: 40),
                                        SizedBox(height: 8),
                                        Text("Add Additional Images"),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text("${additionalImages.length} ảnh đã chọn",
                                  style: const TextStyle(color: Colors.grey)),
                            ]),
                            // ==================== SIZE & COLOR ====================
                            const SizedBox(height: 24),

// Size Selection
                            _buildCard("Kích cỡ (Size)", [
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: availableSizes.map((size) {
                                  final isSelected = selectedSizes.contains(size);
                                  return FilterChip(
                                    label: Text(size,
                                        style: TextStyle(
                                            fontWeight:
                                                isSelected ? FontWeight.bold : FontWeight.normal)),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          selectedSizes.add(size);
                                        } else {
                                          selectedSizes.remove(size);
                                        }
                                      });
                                    },
                                    selectedColor: Colors.blue.shade100,
                                    checkmarkColor: Colors.blue,
                                    backgroundColor: Colors.grey.shade100,
                                  );
                                }).toList(),
                              ),
                            ]),

                            const SizedBox(height: 24),

// Color Selection
                            _buildCard("Màu sắc (Color)", [
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: availableColors.map((color) {
                                  final isSelected = selectedColors.contains(color);
                                  return FilterChip(
                                    label: Text(color),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          selectedColors.add(color);
                                        } else {
                                          selectedColors.remove(color);
                                        }
                                      });
                                    },
                                    selectedColor: Colors.blue.shade100,
                                    checkmarkColor: Colors.blue,
                                    backgroundColor: Colors.grey.shade100,
                                  );
                                }).toList(),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Discard"),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _saveProduct,
                        child: const Text("Save Product"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Future<void> _selectThumbnail() async {
    MediaPickerBottomSheet.show(
      context,
      controller: mediaController,
      onImagesSelected: (images) {
        if (images.isNotEmpty) setState(() => thumbnailUrl = images.first.url);
      },
    );
  }

  Future<void> _selectAdditionalImages() async {
    MediaPickerBottomSheet.show(
      context,
      controller: mediaController,
      onImagesSelected: (images) {
        setState(() {
          additionalImages.addAll(images.map((e) => e.url));
        });
      },
    );
  }

  Future<void> _saveProduct() async {
    if (idController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Vui lòng nhập Product ID")));
      return;
    }
    if (titleController.text.isEmpty || thumbnailUrl == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Vui lòng nhập Title và chọn Thumbnail")));
      return;
    }

    final product = ProductModel(
      id: idController.text.trim(),
      title: titleController.text,
      description: descriptionController.text,
      sku: skuController.text,
      brand: BrandModel.fromName(brand),
      price: double.tryParse(priceController.text) ?? 0.0,
      salePrice: double.tryParse(salePriceController.text) ?? 0.0,
      stock: int.tryParse(stockController.text) ?? 0,
      thumbnail: thumbnailUrl!,
      images: additionalImages.isNotEmpty ? additionalImages : [thumbnailUrl!],
      isFeatured: isFeatured,
      productType: productType,
      categoryId: '', // sau có thể thêm dropdown
      searchName: titleController.text.toLowerCase().trim(),

      // ==================== THÊM SIZE & COLOR ====================
      productAttributes: [
        if (selectedSizes.isNotEmpty) ProductAttributeModel(name: "Size", values: selectedSizes),
        if (selectedColors.isNotEmpty) ProductAttributeModel(name: "Color", values: selectedColors),
      ],
      // =========================================================
    );

    try {
      await productController.createProduct(product);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Tạo sản phẩm thành công!")));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }
}
