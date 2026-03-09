import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/api_connect.dart';
import 'package:flutter_application_1/models/upload_state.dart';
import 'package:flutter_application_1/pages/intro.dart';
import 'package:flutter_application_1/services/app_data.dart';
import 'package:flutter_application_1/pages/user/edit_profile.dart';
import 'package:flutter_application_1/pages/user/user_sheets.dart';
import 'package:flutter_application_1/widgets/upload/upload_progress_dialog.dart';
import 'package:flutter_application_1/widgets/custom_dialog.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

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
        UploadProgressDialog.show(stateNotifier: stateNotifier);
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

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200 || response.statusCode == 204) {
          if (response.body.isNotEmpty) {
            final jsonResponse = _tryParseJsonMap(response.body);
            final profileImage = jsonResponse?['profile_image'];
            if (profileImage is String && profileImage.isNotEmpty) {
              appData.setProfileImage(profileImage);
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
        debugPrint('Error uploading profile image: $e');
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
          return RefreshIndicator(
            onRefresh: () async {
              await appData.fetchUserData();
            },
            child: ListView(
              children: [
                SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
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
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                            if (appData.email.isNotEmpty)
                              Text(
                                appData.email,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),

                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildStatItem(
                                  context,
                                  'ผู้ติดตาม',
                                  appData.followersCount,
                                ),
                                Container(
                                  height: 12,
                                  width: 1,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  color: Colors.grey[300],
                                ),
                                _buildStatItem(
                                  context,
                                  'กำลังติดตาม',
                                  appData.followingsCount,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
                                Get.to(() => const EditProfilePage());
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
                              onPressed: () {
                                _showSubscriptionPackages(context);
                              },
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
                                'ยอดเงินคงเหลือ\n${appData.wallet} บาท',
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
                                'รายการชีต\nทั้งหมดของคุณ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: fontButtonSize.toDouble(),
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              onPressed: () => _openUserSheets(appData.uid),
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
    showCustomDialog(
      title: 'ยืนยันออกจากระบบ',
      message: 'คุณต้องการออกจากระบบใช่ไหม?',
      isConfirm: true,
      onOk: () {
        GetStorage().erase();
        Get.offAll(() => const IntroPage());
      },
    );
  }

  void _openUserSheets(String userId) {
    if (userId.isEmpty) {
      showCustomDialog(
        title: 'ไม่พบข้อมูลผู้ใช้',
        message: 'กรุณาเข้าสู่ระบบใหม่แล้วลองอีกครั้ง',
      );
      return;
    }

    Get.to(() => UserSheetsPage(userId: userId));
  }

  Map<String, dynamic>? _tryParseJsonMap(String source) {
    try {
      final dynamic decoded = jsonDecode(source);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (e) {
      debugPrint('Error parsing profile image response JSON: $e');
      return null;
    }
    return null;
  }

  void _showSubscriptionPackages(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'แพ็กเกจสมาชิกพรีเมียม',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildPackageCard(
                        title: 'รายเดือน',
                        price: '฿79.00/เดือน',
                        buttonText: 'ชำระเงินในราคา ฿79.00',
                        onPressed: () {
                          // TODO: Implement payment logic
                          Get.back();
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildPackageCard(
                        title: 'ราย 3 เดือน',
                        price: '฿229.00/3เดือน',
                        subtitles: ['ประหยัดลง 8 บาท เมื่อเทียบกับรายเดือน'],
                        buttonText: 'ชำระเงินในราคา ฿229.00',
                        onPressed: () {
                          // TODO: Implement payment logic
                          Get.back();
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildPackageCard(
                        title: 'รายปี',
                        price: '฿879.00/ปี',
                        subtitles: [
                          'ประหยัดลง 69 บาท เมื่อเทียบกับรายเดือน',
                          'ประหยัดลง 37 บาท เมื่อเทียบกับราย3เดือน',
                        ],
                        buttonText: 'ชำระเงินในราคา ฿879.00',
                        onPressed: () {
                          // TODO: Implement payment logic
                          Get.back();
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPackageCard({
    required String title,
    required String price,
    List<String>? subtitles,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            price,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (subtitles != null && subtitles.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...subtitles.map(
              (text) => Text(
                text,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFF2A5DB9,
                ), // Blue color from screenshot
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: onPressed,
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, int count) {
    return Row(
      children: [
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }
}

class ProgressMultipartRequest extends http.MultipartRequest {
  final void Function(int bytes, int total) onProgress;

  ProgressMultipartRequest(super.method, super.url, {required this.onProgress});

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
