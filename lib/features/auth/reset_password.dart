import 'package:flutter/material.dart';
import 'package:hero_app_flutter/core/services/auth_service.dart';
import 'package:hero_app_flutter/core/utils/api_utils.dart';
import 'package:hero_app_flutter/shared/widgets/custom_dialog.dart';
import 'package:hero_app_flutter/constants/app_colors.dart';
import 'package:hero_app_flutter/constants/app_fonts.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _emailCtl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtl.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    final email = _emailCtl.text.trim();

    if (email.isEmpty) {
      showCustomDialog(
        title: 'ข้อมูลไม่ครบถ้วน',
        message: 'กรุณากรอกอีเมลให้ครบถ้วน',
      );
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      showCustomDialog(
        title: 'อีเมลไม่ถูกต้อง',
        message: 'กรุณากรอกอีเมลให้ถูกต้อง',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await AuthService.requestPasswordReset(email: email);

      if (response.statusCode == 200) {
        showCustomDialog(
          title: 'ส่งอีเมลสำเร็จ',
          message: 'เราได้ส่งลิงก์รีเซ็ตรหัสผ่านไปยังอีเมลของคุณแล้ว',
          isSuccess: true,
          onOk: () {
            if (mounted) {
              Navigator.of(context).maybePop();
            }
          },
        );
        return;
      }

      final String errorMsg = getErrorMessage(response);
      showCustomDialog(title: 'เกิดข้อผิดพลาด', message: errorMsg);
    } catch (e) {
      debugPrint('Error requesting password reset: $e');
      showCustomDialog(
        title: 'เกิดข้อผิดพลาด',
        message: 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'รีเซ็ตรหัสผ่าน',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.w800),
            ),
            const Text(
              'กรอกอีเมลเพื่อรับลิงก์รีเซ็ตรหัสผ่าน',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF6E6E6E),
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _emailCtl,
              keyboardType: TextInputType.emailAddress,
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
            FilledButton(
              onPressed: _isLoading ? null : _sendResetLink,
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
                      'ส่งลิงก์รีเซ็ตรหัสผ่าน',
                      style: TextStyle(
                        fontFamily: AppFonts.sukhumvit,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
