// controllers/category_controller.dart
import 'package:kc_admin_panel/Admin/models/category/category_model.dart';
import 'package:kc_admin_panel/data/category/category_repository.dart';

class CategoryController {
  final repo = CategoryRepository();

  Stream<List<CategoryModel>> getCategories() => repo.getCategories();

  Future<void> updateCategory(CategoryModel category) => repo.updateCategory(category);

  Future<void> deleteCategory(String id) => repo.deleteCategory(id);

  Future<void> createCategory(CategoryModel category) => repo.createCategory(category);
}
