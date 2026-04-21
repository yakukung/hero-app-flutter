import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/app.dart';
import 'package:flutter_application_1/core/controllers/admin_controller.dart';
import 'package:flutter_application_1/features/auth/register.dart';
import 'package:flutter_application_1/features/auth/reset_password.dart';
import 'package:flutter_application_1/core/controllers/app_controller.dart';
import 'package:flutter_application_1/core/controllers/navigation_controller.dart';
import 'package:flutter_application_1/core/controllers/sheets_controller.dart';
import 'package:flutter_application_1/core/services/auth_service.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/shared/widgets/custom_dialog.dart';
import 'package:flutter_application_1/features/admin/home.dart';
import 'package:flutter_application_1/validations/auth_validators.dart';
import 'package:flutter_application_1/core/utils/api_utils.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/constants/app_fonts.dart';

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
                      validator: validateUsernameOrEmail,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.inputFill,
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
                      validator: validatePassword,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.inputFill,
                        hintText: 'รหัสผ่าน',
                        hintStyle: const TextStyle(
                          fontFamily: AppFonts.sukhumvit,
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
                        fontFamily: AppFonts.sukhumvit,
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
                    onTap: () => Get.to(() => const ResetPasswordPage()),
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
                  backgroundColor: AppColors.primary,
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
                          fontFamily: AppFonts.sukhumvit,
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
                        color: AppColors.inputFill,
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
                        color: AppColors.inputFill,
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
      showCustomDialog(
        title: 'ข้อมูลไม่ครบถ้วน',
        message: 'กรุณากรอกชื่อผู้ใช้และรหัสผ่าน',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AuthService.login(
        usernameOrEmail: _usernameOrEmailCtl.text.trim(),
        password: _passwordCtl.text.trim(),
      );

      if (response.statusCode != 200) {
        _handleInvalidCredentials(getErrorMessage(response));
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
        showCustomDialog(title: 'เข้าสู่ระบบไม่สำเร็จ', message: message);
        return;
      }

      final dynamic data = payload['data'];
      if (data is! Map<String, dynamic>) {
        _showUnexpectedResponse();
        return;
      }

      final String? uid = _extractUid(data);
      if (uid == null || uid.isEmpty) {
        _showUnexpectedResponse();
        return;
      }

      await _completeLogin(uid, data);
    } catch (error) {
      debugPrint('Login error: $error');
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

  void _handleInvalidCredentials(String message) {
    if (!mounted) return;
    showCustomDialog(title: 'เข้าสู่ระบบไม่สำเร็จ', message: message);
  }

  void _showUnexpectedResponse() {
    if (!mounted) return;
    showCustomDialog(
      title: 'เกิดข้อผิดพลาด',
      message: 'ไม่สามารถเข้าสู่ระบบได้ในขณะนี้',
    );
  }

  void _showNetworkError() {
    if (!mounted) return;
    showCustomDialog(
      title: 'เกิดข้อผิดพลาด',
      message: 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ กรุณาลองใหม่ในภายหลัง',
    );
  }

  Map<String, dynamic>? _decodeLoginPayload(String responseBody) {
    try {
      final dynamic decoded = jsonDecode(responseBody);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (error) {
      debugPrint('Error decoding login response: $error');
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
        final response = await authService.loginByGoogle(
          providerUserId: userCredential.user!.uid,
          providerName: "GOOGLE",
          providerUsername: userCredential.user!.displayName ?? "",
          providerEmail: userCredential.user!.email ?? "",
          providerAvatar: userCredential.user!.photoURL ?? "",
        );

        if (response.statusCode != 200) {
          final String errorMsg = getErrorMessage(response);
          showCustomDialog(title: 'เข้าสู่ระบบไม่สำเร็จ', message: errorMsg);
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
          showCustomDialog(title: 'เข้าสู่ระบบไม่สำเร็จ', message: message);
          return;
        }

        final dynamic data = payload['data'];
        if (data is! Map<String, dynamic>) {
          _showUnexpectedResponse();
          return;
        }

        final String? uid = _extractUid(data);
        if (uid == null || uid.isEmpty) {
          _showUnexpectedResponse();
          return;
        }

        await _completeLogin(uid, data);
      }
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      showCustomDialog(
        title: 'เกิดข้อผิดพลาด',
        message:
            'ไม่สามารถเข้าสู่ระบบด้วย Google ได้\nกรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ตแล้วลองใหม่อีกครั้ง',
      );
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
    if (!mounted) return;
    final AppController appCtrl = Get.find<AppController>();
    final SheetsController sheetsCtrl = Get.find<SheetsController>();
    final AdminController adminCtrl = Get.find<AdminController>();
    final NavigationController navCtrl = Get.find<NavigationController>();

    appCtrl.updateFromMap({...userData, 'uid': uid});
    sheetsCtrl.resetState();
    adminCtrl.resetState();

    navCtrl.reset();
    if ((appCtrl.user.value?.roleName ?? '').toUpperCase() == 'ADMIN') {
      Get.offAll(() => const AdminHomePage());
    } else {
      Get.offAll(() => const MainPage());
    }
  }
}
