import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/api_connect.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscurePassword = true;
  bool _obscureCfPassword = true;
  bool isLoading = false;
  String errorText = '';
  bool isDialogShowing = false;
  TextEditingController usernameCtl = TextEditingController();
  TextEditingController emailCtl = TextEditingController();
  TextEditingController passwordCtl = TextEditingController();
  TextEditingController cfPasswordCtl = TextEditingController();

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleCfPasswordVisibility() {
    setState(() {
      _obscureCfPassword = !_obscureCfPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: 40,
          left: 40,
          right: 40,
          bottom: 10,
        ),
        child: Column(
          children: [
            Text(
              'สมัครสมาชิก',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.w800),
            ),
            Text(
              'สร้างบัญชีผู้ใช้ใหม่ของคุณ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF6E6E6E),
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: usernameCtl,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFEBEBED),
                hintText: 'ชื่อผู้ใช้',
                hintStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
                prefixIcon: const Icon(Icons.person, color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailCtl,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFEBEBED),
                hintText: 'อีเมล',
                hintStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
                prefixIcon: const Icon(Icons.mail, color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordCtl,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFEBEBED),
                hintText: 'รหัสผ่าน',
                hintStyle: const TextStyle(
                  fontFamily: 'SukhumvitSet',
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
                prefixIcon: const Icon(Icons.lock, color: Colors.black),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(
                fontFamily: 'SukhumvitSet',
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: cfPasswordCtl,
              obscureText: _obscureCfPassword,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFEBEBED),
                hintText: 'ยืนยันรหัสผ่าน',
                hintStyle: const TextStyle(
                  fontFamily: 'SukhumvitSet',
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
                prefixIcon: const Icon(Icons.lock, color: Colors.black),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCfPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: _toggleCfPasswordVisibility,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(
                fontFamily: 'SukhumvitSet',
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    print('ลืมรหัสผ่าน tapped!');
                  },
                  child: Text(
                    'ลืมรหัสผ่าน?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF6B6B6B),
                    ),
                  ),
                ),
              ),
            ),
            FilledButton(
              onPressed: isLoading ? null : register,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2A5DB9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'ยืนยันลงทะเบียน',
                      style: TextStyle(
                        fontFamily: 'SukhumvitSet',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
            ),

            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: Color(0xFFEBEBED),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    margin: const EdgeInsets.only(right: 10),
                  ),
                ),
                const Text(
                  'หรือ ดำเนินต่อด้วยวิธีอื่น',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                Expanded(
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: Color(0xFFEBEBED),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    margin: const EdgeInsets.only(left: 10),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 24,
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo/google-icon-logo.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void register() async {
    setState(() {
      isLoading = true;
      errorText = '';
    });

    final username = usernameCtl.text.trim();
    final email = emailCtl.text.trim();
    final password = passwordCtl.text;
    final cfPassword = cfPasswordCtl.text;

    // ตรวจสอบข้อมูลเบื้องต้น
    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        cfPassword.isEmpty) {
      setState(() {
        isLoading = false;
      });
      showCustomDialog('ข้อมูลไม่ครบถ้วน', 'กรุณากรอกข้อมูลให้ครบทุกช่อง');
      return;
    }

    // ตรวจสอบรูปแบบอีเมล
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        isLoading = false;
      });
      showCustomDialog('อีเมลไม่ถูกต้อง', 'กรุณากรอกอีเมลให้ถูกต้อง');
      return;
    }

    if (password != cfPassword) {
      setState(() {
        isLoading = false;
      });
      showCustomDialog('รหัสผ่านไม่ตรงกัน', 'กรุณายืนยันรหัสผ่านให้ถูกต้อง');
      return;
    }

    // ตรวจสอบความยาวรหัสผ่าน
    if (password.length < 8) {
      setState(() {
        isLoading = false;
      });
      showCustomDialog(
        'รหัสผ่านสั้นเกินไป',
        'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร',
      );
      return;
    }

    if (password != cfPassword) {
      setState(() {
        isLoading = false;
      });
      showCustomDialog('รหัสผ่านไม่ตรงกัน', 'กรุณายืนยันรหัสผ่านให้ถูกต้อง');
      return;
    }

    log('Register API at $apiEndpoint/auth/register');
    try {
      final response = await http.post(
        Uri.parse('$apiEndpoint/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'confirmPassword': cfPassword,
          'base_url': apiEndpoint,
        }),
      );
      log('Register response: ${response.body}');

      final payload = _decodeRegisterPayload(response.body);
      if (payload == null) {
        setState(() => isLoading = false);
        showCustomDialog(
          'เกิดข้อผิดพลาด',
          'ไม่สามารถสมัครสมาชิกได้ กรุณาลองใหม่',
        );
        return;
      }

      final bool isSuccessful =
          response.statusCode == 200 && _parseApiCode(payload['code']) == 200;

      if (isSuccessful) {
        setState(() => isLoading = false);
        showCustomDialog(
          'สำเร็จ',
          'ตรวจสอบข้อความในอีเมลของคุณ\nเพื่อยืนยันบัญชี',
          isSuccess: true,
          onOk: () {
            Get.offAll(() => const LoginPage());
          },
        );
        return;
      }

      setState(() => isLoading = false);
      final String errorMsg = _extractErrorMessage(payload);
      if (errorMsg.contains('username')) {
        showCustomDialog('ชื่อผู้ใช้ซ้ำ', 'ชื่อผู้ใช้นี้ถูกใช้ไปแล้ว');
      } else if (errorMsg.contains('email')) {
        showCustomDialog('อีเมลซ้ำ', 'อีเมลนี้ถูกใช้ไปแล้ว');
      } else {
        showCustomDialog('เกิดข้อผิดพลาด', errorMsg);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showCustomDialog('เกิดข้อผิดพลาด', 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้');
    }
  }

  Map<String, dynamic>? _decodeRegisterPayload(String responseBody) {
    try {
      final dynamic decoded = jsonDecode(responseBody);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (error) {
      log('Error decoding register response: $error');
      return null;
    }
  }

  int _parseApiCode(dynamic code) {
    if (code is int) return code;
    if (code is String) {
      return int.tryParse(code) ?? 0;
    }
    return 0;
  }

  String _extractErrorMessage(Map<String, dynamic> payload) {
    final dynamic errorField = payload['error'];
    if (errorField is Map<String, dynamic>) {
      final dynamic messageField = errorField['message'];
      if (messageField is Map<String, dynamic>) {
        return messageField['th']?.toString() ??
            messageField['en']?.toString() ??
            messageField.values
                .firstWhere(
                  (value) => value != null,
                  orElse: () => 'ไม่สามารถสมัครสมาชิกได้',
                )
                .toString();
      }
      if (messageField != null) {
        return messageField.toString();
      }
      return errorField.values
          .firstWhere(
            (value) => value != null,
            orElse: () => 'ไม่สามารถสมัครสมาชิกได้',
          )
          .toString();
    }
    if (errorField != null) {
      return errorField.toString();
    }
    return payload['message']?.toString() ?? 'ไม่สามารถสมัครสมาชิกได้';
  }
}

void showCustomDialog(
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
