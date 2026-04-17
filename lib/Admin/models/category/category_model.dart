// models/category_model.dart
class CategoryModel {
  final String id;
  final String name;
  final String image;
  final bool isFeatured;
  final String parentId;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.isFeatured,
    required this.parentId,
  });

  factory CategoryModel.fromFirestore(doc) {
    final data = doc.data();
    return CategoryModel(
      id: doc.id,
      name: data['Name'] ?? '',
      image: data['Image'] ?? '',
      isFeatured: data['IsFeatured'] ?? false,
      parentId: data['ParentId'] ?? '',
    );
  }
}
