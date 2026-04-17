import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kc_admin_panel/Admin/models/coupons/coupon_model.dart';


class CouponRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<CouponModel>> getCoupons() {
    return _db.collection('Coupons').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => CouponModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> createCoupon(CouponModel coupon) async {
    final doc = _db.collection('Coupons').doc(coupon.id);

    final existing = await doc.get();
    if (existing.exists) {
      throw Exception("ID đã tồn tại");
    }

    await doc.set(coupon.toMap());
  }

  Future<void> updateCoupon(CouponModel coupon) async {
    await _db.collection('Coupons').doc(coupon.id).update(coupon.toMap());
  }

  Future<void> deleteCoupon(String id) async {
    await _db.collection('Coupons').doc(id).delete();
  }
}