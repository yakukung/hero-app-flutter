import 'dart:developer';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/api_connect.dart';
import 'package:flutter_application_1/services/app_data.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_application_1/widgets/custom_dialog.dart';

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

  Future<void> _changeUsername() async {
    final appData = Provider.of<Appdata>(context, listen: false);
    final newUsername = _usernameCtl.text.trim();

    if (newUsername.isEmpty) {
      showCustomDialog(
        title: 'ข้อมูลไม่ครบถ้วน',
        message: 'กรุณากรอกชื่อผู้ใช้',
      );
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
          showCustomDialog(
            title: 'สำเร็จ',
            message: 'เปลี่ยนชื่อผู้ใช้สำเร็จ',
            isSuccess: true,
            onOk: () => Navigator.pop(context),
          );
          break;
        default:
          showCustomDialog(
            title: 'เกิดข้อผิดพลาด',
            message: jsonDecode(response.body)['error']?['message']?['th'],
          );
          break;
      }
    } catch (e) {
      log('Error changing username: $e');
      showCustomDialog(
        title: 'เกิดข้อผิดพลาด',
        message: 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้',
      );
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
