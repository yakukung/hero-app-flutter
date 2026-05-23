import 'package:flutter/material.dart';
import 'package:hero_app_flutter/core/controllers/admin_controller.dart';
import 'package:hero_app_flutter/features/admin/admin_design.dart';
import 'package:hero_app_flutter/shared/widgets/custom_dialog.dart';
import 'package:get/get.dart';
import 'package:hero_app_flutter/validations/auth_validators.dart';

class AdminChangePasswordPage extends StatefulWidget {
  final String userId;

  const AdminChangePasswordPage({super.key, required this.userId});

  @override
  State<AdminChangePasswordPage> createState() =>
      _AdminChangePasswordPageState();
}

class _AdminChangePasswordPageState extends State<AdminChangePasswordPage> {
  final AdminController _adminController = Get.find<AdminController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _passwordCtl = TextEditingController();
  final _cfPasswordCtl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureCfPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordCtl.dispose();
    _cfPasswordCtl.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState?.validate() != true) return;

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
      final success = await _adminController.updateUserPassword(
        widget.userId,
        newPassword,
      );

      if (success) {
        if (mounted) {
          showCustomDialog(
            title: 'สำเร็จ',
            message: 'เปลี่ยนรหัสผ่านสำเร็จ',
            isSuccess: true,
            onOk: () => Get.back(result: true),
          );
        }
      } else {
        if (mounted) {
          showCustomDialog(
            title: 'เกิดข้อผิดพลาด',
            message: _adminController.errorMessage.value.isNotEmpty
                ? _adminController.errorMessage.value
                : 'ไม่สามารถเปลี่ยนรหัสผ่านได้',
          );
        }
      }
    } catch (e) {
      debugPrint('Error changing password (admin): $e');
      if (mounted) {
        showCustomDialog(
          title: 'เกิดข้อผิดพลาด',
          message: 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        title: const Text(
          'เปลี่ยนรหัสผ่าน',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AdminColors.text,
          ),
        ),
        backgroundColor: AdminColors.background,
        surfaceTintColor: AdminColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AdminColors.text),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              AdminPageHeader(
                title: 'รหัสผ่านใหม่',
                subtitle: 'ตั้งรหัสผ่านใหม่ให้ผู้ใช้',
                icon: Icons.lock_outline_rounded,
              ),
              const SizedBox(height: 16),
              AdminCard(
                child: TextFormField(
                  controller: _passwordCtl,
                  obscureText: _obscurePassword,
                  validator: validateStrongPassword,
                  decoration: InputDecoration(
                    labelText: 'รหัสผ่านใหม่',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
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
              ),
              const SizedBox(height: 16),
              AdminCard(
                child: TextFormField(
                  controller: _cfPasswordCtl,
                  obscureText: _obscureCfPassword,
                  validator: validateRequiredPassword,
                  decoration: InputDecoration(
                    labelText: 'ยืนยันรหัสผ่านใหม่',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
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
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
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