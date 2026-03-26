import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/config/api_connect.dart';
import 'package:flutter_application_1/core/controllers/app_controller.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/shared/widgets/custom_dialog.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/validations/auth_validators.dart';
import 'package:flutter_application_1/validations/email_validators.dart';
import 'package:flutter_application_1/constants/app_colors.dart';

class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
    final appController = Get.find<AppController>();
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    final newEmail = _emailCtl.text.trim();
    final password = _passwordCtl.text;

    final validationError = validateChangeEmail(
      newEmail: newEmail,
      currentEmail: appController.email,
      password: password,
    );
    if (validationError != null) {
      showCustomDialog(
        title: validationError.title,
        message: validationError.message,
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
          'uid': appController.uid,
          'email': newEmail,
          'password': password,
        }),
      );
      switch (response.statusCode) {
        case 204:
          await appController.fetchUserData();
          showCustomDialog(
            title: 'สำเร็จ',
            message: 'เปลี่ยนอีเมลสำเร็จ',
            isSuccess: true,
            onOk: () => Get.back(),
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
      debugPrint('Error changing email: $e');
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
    final appController = Get.find<AppController>();

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
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              TextFormField(
                key: ValueKey(appController.email),
                initialValue: appController.email,
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
              TextFormField(
                controller: _emailCtl,
                validator: validateEmail,
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
              TextFormField(
                controller: _passwordCtl,
                obscureText: _obscurePassword,
                validator: validateRequiredPassword,
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
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
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
                    backgroundColor: AppColors.primary,
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
      ),
    );
  }
}
