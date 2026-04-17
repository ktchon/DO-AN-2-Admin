

import 'package:kc_admin_panel/Admin/models/coupons/coupon_model.dart';
import 'package:kc_admin_panel/data/coupon/coupon_repository.dart';

class CouponController {
  final repo = CouponRepository();

  Stream<List<CouponModel>> getCoupons() => repo.getCoupons();

  Future<void> createCoupon(CouponModel coupon) =>
      repo.createCoupon(coupon);

  Future<void> updateCoupon(CouponModel coupon) =>
      repo.updateCoupon(coupon);

  Future<void> deleteCoupon(String id) =>
      repo.deleteCoupon(id);
}