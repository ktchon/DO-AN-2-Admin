import 'package:flutter/material.dart';
import 'package:kc_admin_panel/Admin/controllers/media/media_controller.dart';
import 'package:kc_admin_panel/Admin/controllers/profile/profile_controller.dart';
import 'package:kc_admin_panel/Admin/screens/admin_sidebar.dart';
import 'package:kc_admin_panel/Admin/screens/sidebar/admin_header.dart';
import 'package:kc_admin_panel/Admin/screens/bottom_sheet/media_picker_bottom_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final profileController = ProfileController();
  final mediaController = MediaController();

  // Biến lưu giá trị hiện tại (từ service)
  late String firstName;
  late String lastName;
  late String email;
  late String phoneNumber;
  late String profileImageUrl;

  // Biến tạm để chỉnh sửa (không ảnh hưởng đến hiển thị cho đến khi Update)
  String tempFirstName = "";
  String tempLastName = "";
  String tempEmail = "";
  String tempPhoneNumber = "";

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  void _loadCurrentProfile() {
    final profile = profileController.currentProfile;
    firstName = profile.firstName;
    lastName = profile.lastName;
    email = profile.email;
    phoneNumber = profile.phoneNumber;
    profileImageUrl = profile.profileImageUrl;

    // Khởi tạo giá trị tạm
    tempFirstName = firstName;
    tempLastName = lastName;
    tempEmail = email;
    tempPhoneNumber = phoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          const AdminSidebar(currentRoute: '/admin/profile'),
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
                        const Text('Profile',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 30),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar Section
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
                                        onTap: _pickProfileImage,
                                        child: Stack(
                                          alignment: Alignment.bottomRight,
                                          children: [
                                            Container(
                                              width: 180,
                                              height: 180,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Colors.grey.shade300, width: 4),
                                                image: profileImageUrl.isNotEmpty
                                                    ? DecorationImage(
                                                        image: NetworkImage(profileImageUrl),
                                                        fit: BoxFit.cover)
                                                    : null,
                                              ),
                                              child: profileImageUrl.isEmpty
                                                  ? const Icon(Icons.person,
                                                      size: 80, color: Colors.grey)
                                                  : null,
                                            ),
                                            const CircleAvatar(
                                              radius: 22,
                                              backgroundColor: Colors.blue,
                                              child: Icon(Icons.camera_alt,
                                                  size: 20, color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        "$firstName $lastName", // Hiển thị giá trị cũ
                                        style: const TextStyle(
                                            fontSize: 24, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(email, style: const TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 30),

                            // Profile Details Form
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
                                      const Text("Profile Details",
                                          style:
                                              TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 24),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              decoration:  InputDecoration(
                                                labelText: "First Name",
                                                prefixIcon: Icon(Icons.person_outline),
                                                border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(12)),
                                              ),
                                              controller:
                                                  TextEditingController(text: tempFirstName),
                                              onChanged: (value) => tempFirstName = value,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: TextField(
                                              decoration:  InputDecoration(
                                                labelText: "Last Name",
                                                prefixIcon: Icon(Icons.person_outline),
                                                border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(12)),
                                              ),
                                              controller: TextEditingController(text: tempLastName),
                                              onChanged: (value) => tempLastName = value,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      TextField(
                                        decoration:  InputDecoration(
                                          labelText: "Email",
                                          prefixIcon: Icon(Icons.email_outlined),
                                          border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12)),
                                        ),
                                        controller: TextEditingController(text: tempEmail),
                                        onChanged: (value) => tempEmail = value,
                                      ),
                                      const SizedBox(height: 20),
                                      TextField(
                                        decoration:  InputDecoration(
                                          labelText: "Phone Number",
                                          prefixIcon: Icon(Icons.phone_outlined),
                                          border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12)),
                                        ),
                                        controller: TextEditingController(text: tempPhoneNumber),
                                        onChanged: (value) => tempPhoneNumber = value,
                                      ),
                                      const SizedBox(height: 40),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: ElevatedButton(
                                          onPressed: _updateProfile,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blueAccent,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12)),
                                          ),
                                          child: const Text("Cập nhật hồ sơ",
                                              style: TextStyle(color: Colors.white,
                                                  fontSize: 16, fontWeight: FontWeight.w600)),
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

  void _pickProfileImage() {
    MediaPickerBottomSheet.show(
      context,
      controller: mediaController,
      onImagesSelected: (images) {
        if (images.isNotEmpty) {
          setState(() {
            profileImageUrl = images.first.url;
          });
        }
      },
    );
  }

  void _updateProfile() {
    profileController.updateProfile(
      firstName: tempFirstName,
      lastName: tempLastName,
      email: tempEmail,
      phoneNumber: tempPhoneNumber,
      profileImageUrl: profileImageUrl,
    );

    setState(() {
      firstName = tempFirstName;
      lastName = tempLastName;
      email = tempEmail;
      phoneNumber = tempPhoneNumber;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Đã cập nhật thông tin hồ sơ thành công"),
        backgroundColor: Colors.green,
      ),
    );
  }
}
