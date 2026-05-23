import 'package:flutter/material.dart';
import 'package:hero_app_flutter/core/controllers/admin_controller.dart';
import 'package:hero_app_flutter/features/admin/admin_design.dart';
import 'package:hero_app_flutter/shared/widgets/custom_dialog.dart';
import 'package:get/get.dart';
import 'package:hero_app_flutter/validations/email_validators.dart';

class AdminChangeEmailPage extends StatefulWidget {
  final String userId;
  final String currentEmail;

  const AdminChangeEmailPage({
    super.key,
    required this.userId,
    required this.currentEmail,
  });

  @override
  State<AdminChangeEmailPage> createState() => _AdminChangeEmailPageState();
}

class _AdminChangeEmailPageState extends State<AdminChangeEmailPage> {
  final AdminController _adminController = Get.find<AdminController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _emailCtl = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailCtl.text = widget.currentEmail;
  }

  @override
  void dispose() {
    _emailCtl.dispose();
    super.dispose();
  }

  Future<void> _changeEmail() async {
    if (_formKey.currentState?.validate() != true) return;

    final newEmail = _emailCtl.text.trim();
    if (newEmail == widget.currentEmail) {
      Get.back();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await _adminController.updateUserEmail(
        widget.userId,
        newEmail,
      );

      if (success) {
        if (mounted) {
          showCustomDialog(
            title: 'สำเร็จ',
            message: 'เปลี่ยนอีเมลสำเร็จ',
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
                : 'ไม่สามารถเปลี่ยนอีเมลได้',
          );
        }
      }
    } catch (e) {
      debugPrint('Error changing email (admin): $e');
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
          'เปลี่ยนอีเมล',
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
                title: 'อีเมลใหม่',
                subtitle: 'แก้ไขอีเมลของผู้ใช้',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),
              AdminCard(
                child: TextFormField(
                  controller: _emailCtl,
                  validator: validateEmail,
                  decoration: const InputDecoration(
                    labelText: 'อีเมลใหม่',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _changeEmail,
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