import 'package:flutter/material.dart';
import 'package:hero_app_flutter/core/controllers/app_controller.dart';
import 'package:hero_app_flutter/core/services/users_service.dart';
import 'package:hero_app_flutter/core/utils/api_utils.dart';
import 'package:hero_app_flutter/shared/widgets/custom_dialog.dart';
import 'package:get/get.dart';
import 'package:hero_app_flutter/constants/app_colors.dart';
import 'package:hero_app_flutter/validations/auth_validators.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    final appController = Get.find<AppController>();
    final newPassword = _passwordCtl.text;
    final cfPassword = _cfPasswordCtl.text;

    if (newPassword != cfPassword) {
      showCustomDialog(
        title: 'รหัสผ่านไม่ตรงกัน',
        message: 'รหัสผ่านใหม่ไม่ตรงกัน',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await UsersService.updatePassword(
        uid: appController.uid,
        oldPassword: _oldPasswordCtl.text,
        newPassword: newPassword,
      );
      switch (response.statusCode) {
        case 204:
          showCustomDialog(
            title: 'สำเร็จ',
            message: 'เปลี่ยนรหัสผ่านสำเร็จ',
            isSuccess: true,
            onOk: () => Get.back(),
          );
          break;
        default:
          showCustomDialog(
            title: 'เปลี่ยนรหัสผ่านไม่สำเร็จ',
            message: getErrorMessage(response),
          );
          break;
      }
    } catch (e) {
      debugPrint('Error changing password: $e');
      showCustomDialog(
        title: 'เกิดข้อผิดพลาด',
        message: 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                controller: _oldPasswordCtl,
                obscureText: _obscureOldPassword,
                validator: validateRequiredPassword,
                decoration: _decoration('รหัสผ่านเดิม').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureOldPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () => setState(
                      () => _obscureOldPassword = !_obscureOldPassword,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _passwordCtl,
                obscureText: _obscurePassword,
                validator: validateStrongPassword,
                decoration: _decoration('รหัสผ่านใหม่').copyWith(
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
              const SizedBox(height: 24),
              TextFormField(
                controller: _cfPasswordCtl,
                obscureText: _obscureCfPassword,
                validator: validateRequiredPassword,
                decoration: _decoration('ยืนยันรหัสผ่านใหม่').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCfPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () => setState(
                      () => _obscureCfPassword = !_obscureCfPassword,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _changePassword,
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
      ),
    );
  }
}
