class AppSettingsModel {
  final String appName;
  final String appIconUrl;

  AppSettingsModel({
    required this.appName,
    required this.appIconUrl,
  });

  // Default values
  factory AppSettingsModel.defaultSettings() {
    return AppSettingsModel(
      appName: "My App",
      appIconUrl: "", 
    );
  }
}