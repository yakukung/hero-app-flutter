import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/api_connect.dart';
import 'package:flutter_application_1/services/app_data.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_application_1/widgets/custom_dialog.dart';

class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  final _emailCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtl.dispose();
    _passwordCtl.dispose();
    super.dispose();
  }

  Future<void> _changeEmail() async {
    final appData = Provider.of<Appdata>(context, listen: false);
    final newEmail = _emailCtl.text.trim();
    final password = _passwordCtl.text;

    if (newEmail.isEmpty || password.isEmpty) {
      showCustomDialog(
        title: 'ข้อมูลไม่ครบถ้วน',
        message: 'กรุณากรอกข้อมูลให้ครบถ้วน',
      );
      return;
    }

    if (newEmail == appData.email) {
      showCustomDialog(
        title: 'อีเมลซ้ำ',
        message: 'อีเมลใหม่ต้องไม่ซ้ำกับอีเมลเดิม',
      );
      return;
    }

    // Basic email validation
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(newEmail)) {
      showCustomDialog(
        title: 'รูปแบบไม่ถูกต้อง',
        message: 'รูปแบบอีเมลไม่ถูกต้อง',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse('$apiEndpoint/users/update-email');
      final response = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uid': appData.uid,
          'email': newEmail,
          'password': password,
        }),
      );
      switch (response.statusCode) {
        case 204:
          await appData.fetchUserData();
          showCustomDialog(
            title: 'สำเร็จ',
            message: 'เปลี่ยนอีเมลสำเร็จ',
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
      log('Error changing email: $e');
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
    final appData = Provider.of<Appdata>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'เปลี่ยนอีเมล',
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
              controller: TextEditingController(text: appData.email),
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'อีเมลปัจจุบัน',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                suffixIcon: const Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _emailCtl,
              decoration: InputDecoration(
                labelText: 'อีเมลใหม่',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _passwordCtl,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'รหัสผ่านปัจจุบัน (เพื่อยืนยัน)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _changeEmail,
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
                        'บันทึกอีเมลใหม่',
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
