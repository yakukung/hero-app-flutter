import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/api_connect.dart';
import 'package:flutter_application_1/services/app_data.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  String downloadURL = '';
  final fontButtonSize = 14;

  Future<void> _uploadProfileImage() async {
    final appData = Provider.of<Appdata>(context, listen: false);
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      try {
        final file = File(image.path);
        final fileSize = await file.length();
        if (fileSize > 5 * 1024 * 1024) {
          throw Exception('ไฟล์รูปภาพใหญ่เกิน 5MB');
        }

        final String filePath =
            '${appData.uid}/profile/${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
        final Reference storageRef = _storage.ref().child(filePath);

        await storageRef.putFile(File(image.path));
        final String downloadURL = await storageRef.getDownloadURL();
        log('อัปโหลดรูปภาพสำเร็จ: $downloadURL');
        appData.setProfileImage(downloadURL);

        final response = await http.put(
          Uri.parse('$apiEndpoint/users/update-profile'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'uid': appData.uid, 'profile_image': downloadURL}),
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to update profile: ${response.body}');
        }

        log('อัปเดตโปรไฟล์สำเร็จที่ backend');
      } catch (e) {
        log('Error uploading image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('อัปโหลดรูปภาพไม่สำเร็จ: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<Appdata>(
        builder: (context, appData, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: _uploadProfileImage,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white,
                            child: ClipOval(
                              child: appData.profileImage.isNotEmpty
                                  ? Image.network(
                                      appData.profileImage,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'assets/images/default/avatar.png',
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          appData.username.isNotEmpty
                              ? appData.username
                              : 'ชื่อผู้ใช้',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          appData.email.isNotEmpty
                              ? appData.email
                              : 'example@email.com',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFD4E1FF),
                                minimumSize: const Size(0, 86),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                              ),
                              label: Text(
                                'แก้ไขข้อมูลส่วนตัว',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: fontButtonSize.toDouble(),
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              onPressed: () {},
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFD4E1FF),
                                minimumSize: const Size(0, 86),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                              ),
                              label: Text(
                                'แก้ไขแพ็กเกจสมาชิกของคุณ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: fontButtonSize.toDouble(),
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFD4E1FF),
                                minimumSize: const Size(0, 86),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                              ),
                              label: Text(
                                'ยอดเงินคงเหลือ',
                                style: TextStyle(
                                  fontSize: fontButtonSize.toDouble(),
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              onPressed: () {},
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFD4E1FF),
                                minimumSize: const Size(0, 86),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                              ),
                              label: Text(
                                'รายการชีต\nทั้งหมดของคุณ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: fontButtonSize.toDouble(),
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
