import 'package:flutter/material.dart';
import 'package:kc_admin_panel/Admin/models/profile/profile_model.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final ValueNotifier<ProfileModel> profileNotifier = ValueNotifier(
    ProfileModel(
      firstName: "App",
      lastName: "Admin",
      email: "support@shopapp.com",
      phoneNumber: "",
      profileImageUrl: "",
    ),
  );

  ProfileModel get profile => profileNotifier.value;

  void updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
  }) {
    profileNotifier.value = profileNotifier.value.copyWith(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      profileImageUrl: profileImageUrl,
    );
  }
}