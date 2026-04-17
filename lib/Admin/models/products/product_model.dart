import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kc_admin_panel/Admin/models/products/attribute_model.dart';
import 'package:kc_admin_panel/Admin/models/products/brand_model.dart';
import 'package:kc_admin_panel/Admin/models/products/variation_products.dart';

class ProductModel {
  final String id;
  String sku;
  String title;
  int stock;
  double price;
  final DateTime? date;
  double salePrice;
  bool isFeatured;
  String thumbnail;
  String categoryId;
  String description;
  String productType;
  BrandModel? brand;
  List<String> images;
  List<ProductAttributeModel>? productAttributes;
  List<ProductVariationModel>? productVariations;
  final List<String> complementaryProductIds;
  final String searchName;

  ProductModel({
    required this.id,
    this.sku = '',
    this.title = '',
    this.stock = 0,
    this.price = 0.0,
    this.salePrice = 0.0,
    this.isFeatured = false,
    this.thumbnail = '',
    this.categoryId = '',
    this.description = '',
    this.productType = 'ProductType.single',
    this.brand,
    this.images = const [],
    this.productAttributes,
    this.productVariations,
    this.date,
    this.complementaryProductIds = const [],
    this.searchName = '',
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    // Xử lý Brand (có thể là String hoặc Map)
    BrandModel? brandModel;
    if (map['brand'] != null) {
      if (map['brand'] is Map) {
        brandModel = BrandModel.fromMap(map['brand'] as Map<String, dynamic>);
      } else if (map['brand'] is String) {
        brandModel = BrandModel.fromName(map['brand'] as String);
      }
    }

    return ProductModel(
      id: id,
      sku: map['sku']?.toString() ?? '',
      title: map['title']?.toString() ?? map['Title']?.toString() ?? 'Không có tên',
      stock: (map['stock'] ?? map['Stock'] ?? 0) as int,
      price: (map['price'] ?? map['Price'] ?? 0).toDouble(),
      salePrice: (map['salePrice'] ?? map['SalePrice'] ?? 0).toDouble(),
      isFeatured: map['isFeatured'] ?? map['IsFeatured'] ?? false,
      thumbnail: map['thumbnail']?.toString() ?? map['Thumbnail']?.toString() ?? '',
      categoryId: map['categoryId']?.toString() ?? map['CategoryId']?.toString() ?? '',
      description: map['description']?.toString() ?? map['Description']?.toString() ?? '',
      productType:
          map['productType']?.toString() ?? map['ProductType']?.toString() ?? 'ProductType.single',
      brand: brandModel,
      images: List<String>.from(map['images'] ?? map['Images'] ?? []),
      complementaryProductIds: List<String>.from(map['complementaryProductIds'] ?? []),
      searchName: map['searchName']?.toString() ?? map['SearchName']?.toString() ?? '',
      date: map['date'] is Timestamp
          ? (map['date'] as Timestamp).toDate()
          : (map['createdAt'] is Timestamp ? (map['createdAt'] as Timestamp).toDate() : null),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sku': sku,
      'title': title,
      'stock': stock,
      'price': price,
      'salePrice': salePrice,
      'isFeatured': isFeatured,
      'thumbnail': thumbnail,
      'categoryId': categoryId,
      'description': description,
      'productType': productType,
      if (brand != null) 'brand': brand!.toMap(),
      'images': images,
      'complementaryProductIds': complementaryProductIds,
      'searchName': searchName,
      'date': date != null ? Timestamp.fromDate(date!) : FieldValue.serverTimestamp(),
    };
  }
}
