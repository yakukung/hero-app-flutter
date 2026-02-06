import 'dart:developer';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/api_connect.dart';
import 'package:flutter_application_1/services/app_data.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_application_1/widgets/custom_dialog.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _oldPasswordCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  final _cfPasswordCtl = TextEditingController();

  bool _obscureOldPassword = true;
  bool _obscurePassword = true;
  bool _obscureCfPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordCtl.dispose();
    _passwordCtl.dispose();
    _cfPasswordCtl.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final appData = Provider.of<Appdata>(context, listen: false);
    final oldPassword = _oldPasswordCtl.text;
    final newPassword = _passwordCtl.text;
    final cfPassword = _cfPasswordCtl.text;

    if (oldPassword.isEmpty || newPassword.isEmpty || cfPassword.isEmpty) {
      showCustomDialog(
        title: 'ข้อมูลไม่ครบถ้วน',
        message: 'กรุณากรอกข้อมูลให้ครบถ้วน',
      );
      return;
    }

    if (newPassword != cfPassword) {
      showCustomDialog(
        title: 'รหัสผ่านไม่ตรงกัน',
        message: 'รหัสผ่านใหม่ไม่ตรงกัน',
      );
      return;
    }

    if (newPassword.length < 6) {
      showCustomDialog(
        title: 'รหัสผ่านสั้นเกินไป',
        message: 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse('$apiEndpoint/users/update-password');
      final response = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uid': appData.uid,
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );
      switch (response.statusCode) {
        case 204:
          showCustomDialog(
            title: 'สำเร็จ',
            message: 'เปลี่ยนรหัสผ่านสำเร็จ',
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
      log('Error changing password: $e');
      showCustomDialog(
        title: 'เกิดข้อผิดพลาด',
        message: 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggleVisibility,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'เปลี่ยนรหัสผ่าน',
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
            _buildPasswordField(
              label: 'รหัสผ่านเดิม',
              controller: _oldPasswordCtl,
              obscureText: _obscureOldPassword,
              onToggleVisibility: () =>
                  setState(() => _obscureOldPassword = !_obscureOldPassword),
            ),
            const SizedBox(height: 24),
            _buildPasswordField(
              label: 'รหัสผ่านใหม่',
              controller: _passwordCtl,
              obscureText: _obscurePassword,
              onToggleVisibility: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            const SizedBox(height: 24),
            _buildPasswordField(
              label: 'ยืนยันรหัสผ่านใหม่',
              controller: _cfPasswordCtl,
              obscureText: _obscureCfPassword,
              onToggleVisibility: () =>
                  setState(() => _obscureCfPassword = !_obscureCfPassword),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
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
                        'บันทึกรหัสผ่านใหม่',
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
