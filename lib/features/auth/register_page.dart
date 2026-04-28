import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hero_app_flutter/constants/app_colors.dart';
import 'package:hero_app_flutter/constants/app_fonts.dart';
import 'package:hero_app_flutter/features/auth/controllers/auth_flow_controller.dart';
import 'package:hero_app_flutter/features/auth/login_page.dart';
import 'package:hero_app_flutter/features/auth/models/auth_flow_result.dart';
import 'package:hero_app_flutter/features/auth/reset_password.dart';
import 'package:hero_app_flutter/features/auth/widgets/auth_alternative_section.dart';
import 'package:hero_app_flutter/features/auth/widgets/auth_footer_prompt.dart';
import 'package:hero_app_flutter/features/auth/widgets/auth_page_header.dart';
import 'package:hero_app_flutter/shared/widgets/custom_dialog.dart';
import 'package:hero_app_flutter/validations/auth_validators.dart';
import 'package:hero_app_flutter/validations/email_validators.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, this.flowController});

  final AuthFlowController? flowController;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameCtl = TextEditingController();
  final TextEditingController _emailCtl = TextEditingController();
  final TextEditingController _passwordCtl = TextEditingController();
  final TextEditingController _confirmPasswordCtl = TextEditingController();

  late final AuthFlowController _flowController;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _flowController = widget.flowController ?? AuthFlowController();
  }

  @override
  void dispose() {
    _usernameCtl.dispose();
    _emailCtl.dispose();
    _passwordCtl.dispose();
    _confirmPasswordCtl.dispose();
    super.dispose();
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
            const AuthPageHeader(
              title: 'สมัครสมาชิก',
              subtitle: 'สร้างบัญชีผู้ใช้ใหม่ของคุณ',
              subtitleFontSize: 18,
            ),
            const SizedBox(height: 40),
            Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  TextFormField(
                    key: const Key('register_username_field'),
                    controller: _usernameCtl,
                    validator: validateUsernameOrEmail,
                    decoration: _inputDecoration(
                      hintText: 'ชื่อผู้ใช้',
                      icon: Icons.person,
                    ),
                    style: _fieldStyle,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    key: const Key('register_email_field'),
                    controller: _emailCtl,
                    validator: validateEmail,
                    decoration: _inputDecoration(
                      hintText: 'อีเมล',
                      icon: Icons.mail,
                    ),
                    style: _fieldStyle,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    key: const Key('register_password_field'),
                    controller: _passwordCtl,
                    obscureText: _obscurePassword,
                    validator: validatePassword,
                    decoration: _passwordDecoration(
                      hintText: 'รหัสผ่าน',
                      obscureValue: _obscurePassword,
                      onToggle: _togglePasswordVisibility,
                    ),
                    style: _passwordFieldStyle,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    key: const Key('register_confirm_password_field'),
                    controller: _confirmPasswordCtl,
                    obscureText: _obscureConfirmPassword,
                    validator: _validateConfirmPassword,
                    decoration: _passwordDecoration(
                      hintText: 'ยืนยันรหัสผ่าน',
                      obscureValue: _obscureConfirmPassword,
                      onToggle: _toggleConfirmPasswordVisibility,
                    ),
                    style: _passwordFieldStyle,
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
              key: const Key('register_submit_button'),
              onPressed: _isLoading ? null : _handleRegister,
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
            AuthAlternativeSection(onGoogleTap: _handleGoogleLogin),
            const SizedBox(height: 20),
            AuthFooterPrompt(
              prompt: 'มีบัญชีอยู่แล้ว?',
              actionLabel: 'เข้าสู่ระบบ',
              onTap: () => Get.to(() => const LoginPage()),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle get _fieldStyle =>
      const TextStyle(fontWeight: FontWeight.w800, fontSize: 16);

  TextStyle get _passwordFieldStyle => const TextStyle(
    fontFamily: AppFonts.sukhumvit,
    fontWeight: FontWeight.w800,
    fontSize: 16,
  );

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.inputFill,
      hintText: hintText,
      hintStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
      prefixIcon: Icon(icon, color: Colors.black),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }

  InputDecoration _passwordDecoration({
    required String hintText,
    required bool obscureValue,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.inputFill,
      hintText: hintText,
      hintStyle: const TextStyle(
        fontFamily: AppFonts.sukhumvit,
        fontWeight: FontWeight.w800,
        fontSize: 16,
      ),
      prefixIcon: const Icon(Icons.lock, color: Colors.black),
      suffixIcon: IconButton(
        icon: Icon(obscureValue ? Icons.visibility_off : Icons.visibility),
        onPressed: onToggle,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }

  String? _validateConfirmPassword(String? value) {
    final requiredValidation = validateRequiredPassword(value);
    if (requiredValidation != null) {
      return requiredValidation;
    }

    if ((value ?? '') != _passwordCtl.text) {
      return 'กรุณายืนยันรหัสผ่านให้ถูกต้อง';
    }

    return null;
  }

  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  Future<void> _handleRegister() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    final result = await _flowController.register(
      username: _usernameCtl.text,
      email: _emailCtl.text,
      password: _passwordCtl.text,
      confirmPassword: _confirmPasswordCtl.text,
    );
    await _handleResult(result);
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    final result = await _flowController.loginWithGoogle();
    await _handleResult(result);
  }

  Future<void> _handleResult(AuthFlowResult result) async {
    if (!mounted) {
      return;
    }

    setState(() => _isLoading = false);

    if (result.status == AuthFlowStatus.cancelled) {
      return;
    }

    if (result.status == AuthFlowStatus.needsVerification) {
      await showCustomDialog(
        title: result.title,
        message: result.message,
        isSuccess: true,
        onOk: () {
          Get.offAll(() => const LoginPage());
        },
      );
      return;
    }

    if (result.isSuccess && result.destination != null) {
      Get.offAll(() => const LoginPage());
      return;
    }

    if (result.shouldShowDialog) {
      await showCustomDialog(title: result.title, message: result.message);
    }
  }
}
