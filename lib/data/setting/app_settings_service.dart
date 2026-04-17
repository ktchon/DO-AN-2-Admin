import 'package:flutter/material.dart';
import 'package:kc_admin_panel/Admin/models/setting/setting_model.dart';

class AppSettingsService {
  static final AppSettingsService _instance = AppSettingsService._internal();
  factory AppSettingsService() => _instance;
  AppSettingsService._internal();

  final ValueNotifier<AppSettingsModel> settingsNotifier = ValueNotifier(
    AppSettingsModel(appName: "My App", appIconUrl: ""),
  );

  AppSettingsModel get settings => settingsNotifier.value;

  void updateSettings(String newAppName, String newAppIconUrl) {
    settingsNotifier.value = AppSettingsModel(
      appName: newAppName,
      appIconUrl: newAppIconUrl,
    );
  }
}