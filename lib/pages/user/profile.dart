import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/api_connect.dart';
import 'package:flutter_application_1/models/upload_state.dart';
import 'package:flutter_application_1/pages/intro.dart';
import 'package:flutter_application_1/services/app_data.dart';
import 'package:flutter_application_1/pages/user/edit_profile.dart';
import 'package:flutter_application_1/widgets/upload/upload_progress_dialog.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();

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
      final stateNotifier = ValueNotifier(const UploadState(isUploading: true));
      if (mounted) {
        UploadProgressDialog.show(
          context: context,
          stateNotifier: stateNotifier,
        );
      }

      try {
        final file = File(image.path);
        final fileSize = await file.length();
        if (fileSize > 5 * 1024 * 1024) {
          throw Exception('ไฟล์รูปภาพใหญ่เกิน 5MB');
        }

        final uri = Uri.parse('$apiEndpoint/users/update-profile-image');
        final request = ProgressMultipartRequest(
          'PUT',
          uri,
          onProgress: (int bytes, int total) {
            final progress = bytes / total;
            stateNotifier.value = stateNotifier.value.copyWith(
              progress: progress,
            );
          },
        );

        request.fields['uid'] = appData.uid;

        String mimeType = 'image/jpeg';
        if (file.path.endsWith('.png')) {
          mimeType = 'image/png';
        } else if (file.path.endsWith('.jpg') || file.path.endsWith('.jpeg')) {
          mimeType = 'image/jpeg';
        }

        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_image',
            file.path,
            contentType: MediaType.parse(mimeType),
          ),
        );

        log('กำลังอัปโหลดรูปภาพไปยัง backend...');
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200 || response.statusCode == 204) {
          log('อัปเดตโปรไฟล์สำเร็จที่ backend: ${response.body}');
          if (response.body.isNotEmpty) {
            try {
              final jsonResponse = jsonDecode(response.body);
              if (jsonResponse['profile_image'] != null) {
                appData.setProfileImage(jsonResponse['profile_image']);
              }
            } catch (e) {
              log('Error parsing response: $e');
            }
          } else {
            await appData.fetchUserData();
            appData.setProfileImage(appData.profileImage);
          }

          stateNotifier.value = stateNotifier.value.copyWith(
            isUploading: false,
            isSuccess: true,
            progress: 1.0,
          );
        } else {
          throw Exception(
            'Failed to update profile: ${response.statusCode} ${response.body}',
          );
        }
      } catch (e) {
        log('Error uploading image: $e');
        stateNotifier.value = stateNotifier.value.copyWith(
          isUploading: false,
          isSuccess: false,
          errorMessage: 'อัปโหลดรูปภาพไม่สำเร็จ: ${e.toString()}',
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
                              color: Color(0xFF2A5DB9),
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
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const EditProfilePage(),
                                  ),
                                );
                              },
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
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            minimumSize: const Size.fromHeight(60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.logout, color: Colors.black),
                          label: Text(
                            'ออกจากระบบ',
                            style: TextStyle(
                              fontSize: fontButtonSize.toDouble(),
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          onPressed: () => _showLogoutConfirmation(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: const SizedBox(),
            ),
          ),
          Container(
            height: 350,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(45)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 6,
                  margin: const EdgeInsets.only(bottom: 60),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const Text(
                  'ยืนยันออกจากระบบ',
                  style: TextStyle(
                    fontFamily: 'SukhumvitSet',
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'คุณต้องการออกจากระบบใช่ไหม?',
                  style: TextStyle(
                    fontFamily: 'SukhumvitSet',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF6E6E6E),
                  ),
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'ยกเลิก',
                          style: TextStyle(
                            fontFamily: 'SukhumvitSet',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        GetStorage().erase();
                        Get.offAll(() => IntroPage());
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'ออกจากระบบ',
                          style: TextStyle(
                            fontFamily: 'SukhumvitSet',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFFF92A47),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressMultipartRequest extends http.MultipartRequest {
  final void Function(int bytes, int total) onProgress;

  ProgressMultipartRequest(String method, Uri url, {required this.onProgress})
    : super(method, url);

  @override
  http.ByteStream finalize() {
    final byteStream = super.finalize();
    final total = contentLength;
    int bytes = 0;

    final t = StreamTransformer.fromHandlers(
      handleData: (List<int> data, EventSink<List<int>> sink) {
        bytes += data.length;
        onProgress(bytes, total);
        sink.add(data);
      },
    );
    final stream = byteStream.transform(t);
    return http.ByteStream(stream);
  }
}
