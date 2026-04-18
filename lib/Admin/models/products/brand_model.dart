class BrandModel {
  final String id;
  final String name;
  final String? image;

  BrandModel({
    required this.id,
    required this.name,
    this.image,
  });

  factory BrandModel.fromMap(Map<String, dynamic> map, String id) {
    return BrandModel(
      id: id,
      name: map['Name'] ?? map['name'] ?? '',
      image: map['Image'] ?? map['image'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'Name': name,
      'Image': image,
    };
  }

  // Tạo nhanh từ String (dùng khi tạo sản phẩm mới)
  static BrandModel fromName(String name) {
    return BrandModel(
      id: name.toLowerCase().replaceAll(' ', '_'),
      name: name,
    );
  }
}
