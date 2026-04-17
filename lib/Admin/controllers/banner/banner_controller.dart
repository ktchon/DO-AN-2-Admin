import 'package:kc_admin_panel/Admin/models/banner/banner_models.dart';
import 'package:kc_admin_panel/data/repositories/banner/banner_repository.dart';

class BannerController {
  final repo = BannerRepository();

  Stream<List<BannerModel>> getBanners() => repo.getBanners();

  Future<String> createBanner({
    required String imageUrl,
    required String targetScreen,
    required bool active,
  }) =>
      repo.createBanner(
        imageUrl: imageUrl,
        targetScreen: targetScreen,
        active: active,
      );

  Future<void> updateBanner(BannerModel banner) => repo.updateBanner(banner);
  Future<void> deleteBanner(String id) => repo.deleteBanner(id);
}
