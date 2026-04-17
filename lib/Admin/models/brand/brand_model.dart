class BrandModel {
  final String id;
  final String name;
  final String image;
  final bool isFeatured;
  final int productsCount;

  BrandModel({
    required this.id,
    required this.name,
    required this.image,
    required this.isFeatured,
    required this.productsCount,
  });

  factory BrandModel.fromFirestore(Map<String, dynamic> data, String id) {
    return BrandModel(
      id: id,
      name: data['Name'] ?? '',
      image: data['Image'] ?? '',
      isFeatured: data['IsFeatured'] ?? false,
      productsCount: data['ProductsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'Image': image,
      'IsFeatured': isFeatured,
      'ProductsCount': productsCount,
    };
  }
}
