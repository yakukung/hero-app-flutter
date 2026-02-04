import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/api_connect.dart';
import 'package:flutter_application_1/app.dart';
import 'package:flutter_application_1/pages/register.dart';
import 'package:flutter_application_1/services/app_data.dart';
import 'package:flutter_application_1/services/navigation_service.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameOrEmailCtl = TextEditingController();
  final TextEditingController _passwordCtl = TextEditingController();
  bool _isPasswordHidden = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameOrEmailCtl.dispose();
    _passwordCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Column(
                children: [
                  Text(
                    'ยินดีต้อนรับ',
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'เข้าสู่ระบบของคุณ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF6E6E6E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameOrEmailCtl,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'กรุณากรอกชื่อผู้ใช้หรืออีเมล';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFEBEBED),
                        hintText: 'ชื่อผู้ใช้ หรือ อีเมล',
                        hintStyle: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Colors.black,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordCtl,
                      obscureText: _isPasswordHidden,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'กรุณากรอกรหัสผ่าน';
                        }
                        if (value.trim().length < 6) {
                          return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                        }
                        return null;
                      },
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
                            _isPasswordHidden
                                ? Icons.visibility_off
                                : Icons.visibility,
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
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => log('Forgot password tapped'),
                    child: const Text(
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
                onPressed: _isLoading ? null : _handleLogin,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2A5DB9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'เข้าสู่ระบบ',
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
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBEBED),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const Text(
                    'หรือ ดำเนินต่อด้วยวิธีอื่น',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                  Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBEBED),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _handleGoogleLogin,
                    child: CircleAvatar(
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
                  ),
                ],
              ),
              const SizedBox(height: 120),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'หากคุณยังไม่มีบัญชี?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(width: 30),
                  GestureDetector(
                    onTap: () => Get.to(() => RegisterPage()),
                    child: const Text(
                      'สมัครสมาชิกใหม่',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Color(0xFF1F8CE2),
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFF1F8CE2),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordHidden = !_isPasswordHidden;
    });
  }

  Future<void> _handleLogin() async {
    if (!_isFormValid()) {
      _showErrorDialog('ข้อมูลไม่ครบถ้วน', 'กรุณากรอกชื่อผู้ใช้และรหัสผ่าน');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$apiEndpoint/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usernameOrEmail': _usernameOrEmailCtl.text.trim(),
          'password': _passwordCtl.text.trim(),
        }),
      );
      log(response.body);

      if (response.statusCode != 200) {
        _handleInvalidCredentials();
        return;
      }

      final payload = _decodeLoginPayload(response.body);
      if (payload == null) {
        _showUnexpectedResponse();
        return;
      }

      final int apiCode = _parseApiCode(payload['code']);
      if (apiCode != 200) {
        final String message =
            payload['message']?.toString() ??
            'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง';
        _showErrorDialog('เข้าสู่ระบบไม่สำเร็จ', message);
        return;
      }

      final dynamic data = payload['data'];
      if (data is! Map<String, dynamic>) {
        log('Error: data field missing or invalid in response');
        _showUnexpectedResponse();
        return;
      }

      final String? uid = _extractUid(data);
      if (uid == null || uid.isEmpty) {
        log('Error: uid is null in response');
        _showUnexpectedResponse();
        return;
      }

      await _completeLogin(uid, data);
    } catch (error) {
      log('Login error: $error');
      _showNetworkError();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _isFormValid() {
    final formState = _formKey.currentState;
    if (formState == null) return false;
    return formState.validate();
  }

  void _handleInvalidCredentials() {
    if (!mounted) return;
    _showErrorDialog(
      'เข้าสู่ระบบไม่สำเร็จ',
      'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง',
    );
  }

  void _showUnexpectedResponse() {
    if (!mounted) return;
    _showErrorDialog('เกิดข้อผิดพลาด', 'ไม่สามารถเข้าสู่ระบบได้ในขณะนี้');
  }

  void _showNetworkError() {
    if (!mounted) return;
    _showErrorDialog(
      'เกิดข้อผิดพลาด',
      'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ กรุณาลองใหม่ในภายหลัง',
    );
  }

  Map<String, dynamic>? _decodeLoginPayload(String responseBody) {
    try {
      final dynamic decoded = jsonDecode(responseBody);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (error) {
      log('Error decoding login response: $error');
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

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final authService = AuthService();
      final userCredential = await authService.signInWithGoogle();

      if (userCredential != null && userCredential.user != null) {
        log('Google Sign-In Success: ${userCredential.user!.uid}');

        final response = await authService.loginByGoogle(
          providerUserId: userCredential.user!.uid,
          providerName: "GOOGLE",
          providerUsername: userCredential.user!.displayName ?? "",
          providerEmail: userCredential.user!.email ?? "",
          providerAvatar: userCredential.user!.photoURL ?? "",
        );

        log('Google Login API Response: ${response.body}');

        if (response.statusCode != 200) {
          _showErrorDialog(
            'เข้าสู่ระบบไม่สำเร็จ',
            'เชื่อมต่อกับเซิร์ฟเวอร์ล้มเหลว',
          );
          return;
        }

        final payload = _decodeLoginPayload(response.body);
        if (payload == null) {
          _showUnexpectedResponse();
          return;
        }

        final int apiCode = _parseApiCode(payload['code']);
        if (apiCode != 200) {
          final String message =
              payload['message']?.toString() ??
              'เกิดข้อผิดพลาดในการเข้าสู่ระบบ';
          _showErrorDialog('เข้าสู่ระบบไม่สำเร็จ', message);
          return;
        }

        final dynamic data = payload['data'];
        if (data is! Map<String, dynamic>) {
          log('Error: data field missing or invalid in response');
          _showUnexpectedResponse();
          return;
        }

        final String? uid = _extractUid(data);
        if (uid == null || uid.isEmpty) {
          log('Error: uid is null in response');
          _showUnexpectedResponse();
          return;
        }

        await _completeLogin(uid, data);
      } else {
        // Cancelled or failed
        log('Google Sign-In cancelled or failed');
      }
    } catch (e) {
      log('Google Sign-In Error: $e');
      _showErrorDialog('เกิดข้อผิดพลาด', 'ไม่สามารถเข้าสู่ระบบด้วย Google ได้');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _extractUid(Map<String, dynamic> data) {
    final dynamic uidValue = data['uid'] ?? data['id'];
    return uidValue?.toString();
  }

  Future<void> _completeLogin(String uid, Map<String, dynamic> userData) async {
    final storage = GetStorage();
    storage.write('uid', uid);
    log('GetStorage: uid=$uid saved');

    if (!mounted) return;
    final appData = Provider.of<Appdata>(context, listen: false);
    appData.updateFromMap(userData);
    await appData.fetchUserData();

    final NavigationService navService = Get.find<NavigationService>();
    navService.currentIndex.value = 0;

    Get.offAll(() => const MainPage());
  }

  void _showErrorDialog(String title, String message) {
    Get.defaultDialog(
      title: '',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFDEEEF),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(18),
            child: const Icon(
              Icons.error_outline,
              color: Color(0xFFF92A47),
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
                foregroundColor: const Color(0xFFF92A47),
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
              onPressed: Get.back,
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
}
