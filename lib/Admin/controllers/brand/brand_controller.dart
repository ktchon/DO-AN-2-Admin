import 'package:kc_admin_panel/Admin/models/brand/brand_model.dart';
import 'package:kc_admin_panel/data/brand/brand_repository.dart';


class BrandController {
  final repo = BrandRepository();

  Stream<List<BrandModel>> getBrands() => repo.getBrands();

  Future<void> updateBrand(BrandModel brand) =>
      repo.updateBrand(brand);

  Future<void> deleteBrand(String id) =>
      repo.deleteBrand(id);
  Future<void> createBrand(BrandModel brand) =>
    repo.createBrand(brand);
}