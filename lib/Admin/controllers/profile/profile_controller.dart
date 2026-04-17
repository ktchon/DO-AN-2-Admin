import 'package:kc_admin_panel/data/profile/profile_service.dart';
import '../../models/profile/profile_model.dart';

class ProfileController {
  final service = ProfileService();

  ProfileModel get currentProfile => service.profile;

  void updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
  }) {
    service.updateProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      profileImageUrl: profileImageUrl,
    );
  }
}