import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hero_app_flutter/app/app.dart';
import 'package:hero_app_flutter/constants/app_colors.dart';
import 'package:hero_app_flutter/constants/app_fonts.dart';
import 'package:hero_app_flutter/core/session/app_session_coordinator.dart';
import 'package:hero_app_flutter/features/admin/admin_home_page.dart';
import 'package:hero_app_flutter/features/auth/controllers/auth_flow_controller.dart';
import 'package:hero_app_flutter/features/auth/models/auth_flow_result.dart';
import 'package:hero_app_flutter/features/auth/register_page.dart';
import 'package:hero_app_flutter/features/auth/reset_password.dart';
import 'package:hero_app_flutter/features/auth/widgets/auth_alternative_section.dart';
import 'package:hero_app_flutter/features/auth/widgets/auth_footer_prompt.dart';
import 'package:hero_app_flutter/features/auth/widgets/auth_page_header.dart';
import 'package:hero_app_flutter/shared/widgets/custom_dialog.dart';
import 'package:hero_app_flutter/validations/auth_validators.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.flowController});

  final AuthFlowController? flowController;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameOrEmailCtl = TextEditingController();
  final TextEditingController _passwordCtl = TextEditingController();

  late final AuthFlowController _flowController;

  bool _isPasswordHidden = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _flowController = widget.flowController ?? AuthFlowController();
  }

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
              const AuthPageHeader(
                title: 'ยินดีต้อนรับ',
                subtitle: 'เข้าสู่ระบบของคุณ',
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    TextFormField(
                      key: const Key('login_username_field'),
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
                      key: const Key('login_password_field'),
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
                key: const Key('login_submit_button'),
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
              AuthAlternativeSection(onGoogleTap: _handleGoogleLogin),
              const SizedBox(height: 120),
              AuthFooterPrompt(
                prompt: 'หากคุณยังไม่มีบัญชี?',
                actionLabel: 'สมัครสมาชิกใหม่',
                onTap: () => Get.to(() => const RegisterPage()),
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
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    final result = await _flowController.login(
      usernameOrEmail: _usernameOrEmailCtl.text,
      password: _passwordCtl.text,
    );
    await _handleAuthResult(result);
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    final result = await _flowController.loginWithGoogle();
    await _handleAuthResult(result);
  }

  Future<void> _handleAuthResult(AuthFlowResult result) async {
    if (!mounted) {
      return;
    }

    setState(() => _isLoading = false);

    if (result.status == AuthFlowStatus.cancelled) {
      return;
    }

    if (result.isSuccess && result.destination != null) {
      switch (result.destination!) {
        case SessionDestination.adminHome:
          Get.offAll(() => const AdminHomePage());
        case SessionDestination.memberHome:
          Get.offAll(() => const MainPage());
        case SessionDestination.intro:
          Get.offAll(() => const MainPage());
      }
      return;
    }

    if (result.shouldShowDialog) {
      await showCustomDialog(title: result.title, message: result.message);
    }
  }
}
