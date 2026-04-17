class BrandModel {
  final String id;
  final String name;
  final String? image;

  BrandModel({
    required this.id,
    required this.name,
    this.image,
  });

  factory BrandModel.fromMap(Map<String, dynamic> map) {
    return BrandModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      image: map['image'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
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
