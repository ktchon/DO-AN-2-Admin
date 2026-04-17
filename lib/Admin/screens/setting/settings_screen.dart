import 'package:flutter/material.dart';
import 'package:kc_admin_panel/Admin/controllers/media/media_controller.dart';
import 'package:kc_admin_panel/Admin/screens/admin_sidebar.dart';
import 'package:kc_admin_panel/Admin/screens/sidebar/admin_header.dart';
import 'package:kc_admin_panel/Admin/screens/bottom_sheet/media_picker_bottom_sheet.dart';
import 'package:kc_admin_panel/data/setting/app_settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final mediaController = MediaController();

  String appName = "My App";
  String appIconUrl = "";
  double taxRate = 0.05;
  double shippingCost = 500;
  double freeShippingThreshold = 2000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          const AdminSidebar(currentRoute: '/admin/settings'),
          Expanded(
            child: Column(
              children: [
                const AdminHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Cài Đặt',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 30),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // App Icon + Name
                            Expanded(
                              flex: 4,
                              child: Card(
                                color: Colors.white,
                                elevation: 2,
                                shape:
                                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                child: Padding(
                                  padding: const EdgeInsets.all(40),
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () => _pickAppIcon(),
                                        child: Stack(
                                          alignment: Alignment.bottomRight,
                                          children: [
                                            Container(
                                              width: 160,
                                              height: 160,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[100],
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(color: Colors.grey.shade300),
                                              ),
                                              child: appIconUrl.isNotEmpty
                                                  ? ClipRRect(
                                                      borderRadius: BorderRadius.circular(20),
                                                      child: Image.network(appIconUrl,
                                                          fit: BoxFit.cover),
                                                    )
                                                  : const Icon(Icons.image,
                                                      size: 60, color: Colors.grey),
                                            ),
                                            const CircleAvatar(
                                              radius: 18,
                                              backgroundColor: Colors.blue,
                                              child: Icon(Icons.camera_alt,
                                                  size: 18, color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(appName,
                                          style: const TextStyle(
                                              fontSize: 20, fontWeight: FontWeight.bold)),
                                      const Text("App Icon", style: TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 30),

                            // App Settings Form
                            Expanded(
                              flex: 6,
                              child: Card(
                                color: Colors.white,
                                elevation: 2,
                                shape:
                                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Cài đặt",
                                          style:
                                              TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 24),
                                      TextField(
                                        decoration: InputDecoration(
                                          labelText: "Tên App",
                                          prefixIcon: const Icon(Icons.text_fields),
                                          border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12)),
                                        ),
                                        controller: TextEditingController(text: appName),
                                        onChanged: (value) => appName = value,
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              decoration: InputDecoration(
                                                labelText: "Thuế (%)",
                                                prefixIcon: const Icon(Icons.percent),
                                                border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(12)),
                                              ),
                                              keyboardType: TextInputType.number,
                                              controller:
                                                  TextEditingController(text: taxRate.toString()),
                                              onChanged: (value) =>
                                                  taxRate = double.tryParse(value) ?? 0.05,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: TextField(
                                              decoration: InputDecoration(
                                                labelText: "Chi phí vận chuyển (\VNĐ)",
                                                prefixIcon: const Icon(Icons.local_shipping),
                                                border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(12)),
                                              ),
                                              keyboardType: TextInputType.number,
                                              controller: TextEditingController(
                                                  text: shippingCost.toString()),
                                              onChanged: (value) =>
                                                  shippingCost = double.tryParse(value) ?? 500,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: TextField(
                                              decoration: InputDecoration(
                                                labelText: "Ngưỡng vận chuyển miễn phí (\VNĐ)",
                                                prefixIcon: const Icon(Icons.card_giftcard),
                                                border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(12)),
                                              ),
                                              keyboardType: TextInputType.number,
                                              controller: TextEditingController(
                                                  text: freeShippingThreshold.toString()),
                                              onChanged: (value) => freeShippingThreshold =
                                                  double.tryParse(value) ?? 2000,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 40),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: ElevatedButton(
                                          onPressed: _updateSettings,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blueAccent,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12)),
                                          ),
                                          child: const Text("Cập nhật",
                                              style: TextStyle(
                                                  color: Colors.white,fontSize: 16, fontWeight: FontWeight.w600)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _pickAppIcon() {
    MediaPickerBottomSheet.show(
      context,
      controller: mediaController,
      onImagesSelected: (images) {
        if (images.isNotEmpty) {
          setState(() {
            appIconUrl = images.first.url;
          });
        }
      },
    );
  }

  void _updateSettings() {
    // Cập nhật vào service (để Sidebar tự động thay đổi)
    AppSettingsService().updateSettings(appName, appIconUrl);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Đã cập nhật cài đặt ứng dụng thành công"),
        backgroundColor: Colors.green,
      ),
    );
  }
}
