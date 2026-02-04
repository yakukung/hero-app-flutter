import 'dart:developer';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/api_connect.dart';
import 'package:flutter_application_1/services/app_data.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class ChangeUsernamePage extends StatefulWidget {
  const ChangeUsernamePage({super.key});

  @override
  State<ChangeUsernamePage> createState() => _ChangeUsernamePageState();
}

class _ChangeUsernamePageState extends State<ChangeUsernamePage> {
  final _usernameCtl = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final appData = Provider.of<Appdata>(context, listen: false);
    _usernameCtl.text = appData.username;
  }

  @override
  void dispose() {
    _usernameCtl.dispose();
    super.dispose();
  }

  void _showDialog(
    String title,
    String message, {
    bool isSuccess = false,
    VoidCallback? onOk,
  }) {
    Get.defaultDialog(
      title: '',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isSuccess
                  ? const Color(0xFFE7F9EE)
                  : const Color(0xFFFDEEEF),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(18),
            child: Icon(
              isSuccess ? Icons.check_circle_outline : Icons.error_outline,
              color: isSuccess
                  ? const Color(0xFF2AB950)
                  : const Color(0xFFF92A47),
              size: 48,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'SukhumvitSet',
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(
              fontFamily: 'SukhumvitSet',
              fontWeight: FontWeight.normal,
              fontSize: 16,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: isSuccess
                    ? const Color(0xFF2AB950)
                    : const Color(0xFFF92A47),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(45),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                  fontFamily: 'SukhumvitSet',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              onPressed: () {
                if (Get.isDialogOpen ?? false) {
                  Get.back();
                }
                onOk?.call();
              },
              child: const Text('ตกลง'),
            ),
          ),
        ],
      ),
      radius: 45,
      backgroundColor: Colors.white,
      barrierDismissible: false,
    );
  }

  Future<void> _changeUsername() async {
    final appData = Provider.of<Appdata>(context, listen: false);
    final newUsername = _usernameCtl.text.trim();

    if (newUsername.isEmpty) {
      _showDialog('ข้อมูลไม่ครบถ้วน', 'กรุณากรอกชื่อผู้ใช้');
      return;
    }

    if (newUsername == appData.username) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // final uri = Uri.parse('$apiEndpoint/users/update-username');
      // final response = await http.patch(
      //   uri,
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({'uid': appData.uid, 'username': newUsername}),
      // );
      // final errorMessage = jsonDecode(response.body)['error']['message']['th'];
      // switch (response.statusCode) {
      //   case 204:
      //     await appData.fetchUserData();
      //     _showDialog(
      //       'สำเร็จ',
      //       'เปลี่ยนชื่อผู้ใช้สำเร็จ',
      //       isSuccess: true,
      //       onOk: () => Navigator.pop(context),
      //     );
      //     break;
      //   default:
      //     _showDialog('เกิดข้อผิดพลาด', errorMessage);
      //     break;
      // }
      final uri = Uri.parse('$apiEndpoint/users/update-username');
      final response = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'uid': appData.uid, 'username': newUsername}),
      );
      switch (response.statusCode) {
        case 204:
          await appData.fetchUserData();
          _showDialog(
            'สำเร็จ',
            'เปลี่ยนชื่อผู้ใช้สำเร็จ',
            isSuccess: true,
            onOk: () => Navigator.pop(context),
          );
          break;
        default:
          _showDialog(
            'เกิดข้อผิดพลาด',
            jsonDecode(response.body)['error']?['message']?['th'],
          );
          break;
      }
    } catch (e) {
      log('Error changing username: $e');
      _showDialog('เกิดข้อผิดพลาด', 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'เปลี่ยนชื่อผู้ใช้',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _usernameCtl,
              decoration: InputDecoration(
                labelText: 'ชื่อผู้ใช้ใหม่',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _changeUsername,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A5DB9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'บันทึกชื่อผู้ใช้ใหม่',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
