import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/app.dart';
import 'package:flutter_application_1/core/config/api_connect.dart';
import 'package:flutter_application_1/core/controllers/admin_controller.dart';
import 'package:flutter_application_1/core/controllers/app_controller.dart';
import 'package:flutter_application_1/core/controllers/navigation_controller.dart';
import 'package:flutter_application_1/core/controllers/sheets_controller.dart';
import 'package:flutter_application_1/features/admin/home.dart';
import 'package:flutter_application_1/core/services/auth_service.dart';
import 'package:flutter_application_1/features/auth/reset_password.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'login.dart';
import 'package:flutter_application_1/shared/widgets/custom_dialog.dart';
import 'package:flutter_application_1/core/utils/api_utils.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/constants/app_fonts.dart';

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

  @override
  void dispose() {
    usernameCtl.dispose();
    emailCtl.dispose();
    passwordCtl.dispose();
    cfPasswordCtl.dispose();
    super.dispose();
  }

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
                fillColor: AppColors.inputFill,
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
                fillColor: AppColors.inputFill,
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
                fontFamily: AppFonts.sukhumvit,
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
                fillColor: AppColors.inputFill,
                hintText: 'ยืนยันรหัสผ่าน',
                hintStyle: const TextStyle(
                  fontFamily: AppFonts.sukhumvit,
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
                fontFamily: AppFonts.sukhumvit,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Get.to(() => const ResetPasswordPage()),
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
                backgroundColor: AppColors.primary,
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
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
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
                      color: AppColors.inputFill,
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
          ],
        ),
      ),
    );
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => isLoading = true);
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
          showCustomDialog(
            title: 'เข้าสู่ระบบไม่สำเร็จ',
            message: errorMsg,
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
        message: 'ไม่สามารถเข้าสู่ระบบด้วย Google ได้\n\nรายละเอียด: $e',
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
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

  void _showUnexpectedResponse() {
    if (!mounted) return;
    showCustomDialog(
      title: 'เกิดข้อผิดพลาด',
      message: 'ไม่สามารถเข้าสู่ระบบได้ในขณะนี้',
    );
  }

  String? _extractUid(Map<String, dynamic> data) {
    final dynamic uidValue = data['uid'] ?? data['id'];
    return uidValue?.toString();
  }

  Future<void> _completeLogin(String uid, Map<String, dynamic> userData) async {
    final storage = GetStorage();
    storage.write('uid', uid);

    if (!mounted) return;
    final appController = Get.find<AppController>();
    final sheetsController = Get.find<SheetsController>();
    final adminController = Get.find<AdminController>();
    final navigationController = Get.find<NavigationController>();

    appController.updateFromMap(userData);
    sheetsController.resetState();
    adminController.resetState();
    navigationController.reset();

    if ((appController.user.value?.roleName ?? '').toUpperCase() == 'ADMIN') {
      Get.offAll(() => const AdminHomePage());
    } else {
      Get.offAll(() => const MainPage());
    }
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

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        cfPassword.isEmpty) {
      setState(() {
        isLoading = false;
      });
      showCustomDialog(
        title: 'ข้อมูลไม่ครบถ้วน',
        message: 'กรุณากรอกข้อมูลให้ครบทุกช่อง',
      );
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        isLoading = false;
      });
      showCustomDialog(
        title: 'อีเมลไม่ถูกต้อง',
        message: 'กรุณากรอกอีเมลให้ถูกต้อง',
      );
      return;
    }

    if (password != cfPassword) {
      setState(() {
        isLoading = false;
      });
      showCustomDialog(
        title: 'รหัสผ่านไม่ตรงกัน',
        message: 'กรุณายืนยันรหัสผ่านให้ถูกต้อง',
      );
      return;
    }

    if (password.length < 6) {
      setState(() {
        isLoading = false;
      });
      showCustomDialog(
        title: 'รหัสผ่านสั้นเกินไป',
        message: 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร',
      );
      return;
    }

    if (password != cfPassword) {
      setState(() {
        isLoading = false;
      });
      showCustomDialog(
        title: 'รหัสผ่านไม่ตรงกัน',
        message: 'กรุณายืนยันรหัสผ่านให้ถูกต้อง',
      );
      return;
    }

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

      if (response.statusCode == 201) {
        setState(() => isLoading = false);
        showCustomDialog(
          title: 'สำเร็จ',
          message: 'ตรวจสอบข้อความในอีเมลของคุณ\nเพื่อยืนยันบัญชี',
          isSuccess: true,
          onOk: () {
            Get.offAll(() => const LoginPage());
          },
        );
        return;
      }
      setState(() => isLoading = false);
      final String errorMsg = getErrorMessage(response);
      showCustomDialog(title: 'เกิดข้อผิดพลาด', message: errorMsg);
    } catch (e) {
      debugPrint('Error registering user: $e');
      setState(() {
        isLoading = false;
      });
      showCustomDialog(
        title: 'เกิดข้อผิดพลาด',
        message: 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้',
      );
    }
  }
}
