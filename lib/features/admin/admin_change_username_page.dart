import 'package:flutter/material.dart';
import 'package:hero_app_flutter/core/controllers/admin_controller.dart';
import 'package:hero_app_flutter/features/admin/admin_design.dart';
import 'package:hero_app_flutter/shared/widgets/custom_dialog.dart';
import 'package:get/get.dart';

class AdminChangeUsernamePage extends StatefulWidget {
  final String userId;
  final String currentUsername;

  const AdminChangeUsernamePage({
    super.key,
    required this.userId,
    required this.currentUsername,
  });

  @override
  State<AdminChangeUsernamePage> createState() =>
      _AdminChangeUsernamePageState();
}

class _AdminChangeUsernamePageState extends State<AdminChangeUsernamePage> {
  final AdminController _adminController = Get.find<AdminController>();
  late TextEditingController _usernameCtl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameCtl = TextEditingController(text: widget.currentUsername);
  }

  @override
  void dispose() {
    _usernameCtl.dispose();
    super.dispose();
  }

  Future<void> _changeUsername() async {
    final newUsername = _usernameCtl.text.trim();

    if (newUsername.isEmpty) {
      showCustomDialog(
        title: 'ข้อมูลไม่ครบถ้วน',
        message: 'กรุณากรอกชื่อผู้ใช้',
      );
      return;
    }

    if (newUsername == widget.currentUsername) {
      Get.back();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await _adminController.updateUserUsername(
        widget.userId,
        newUsername,
      );

      if (success) {
        if (mounted) {
          showCustomDialog(
            title: 'สำเร็จ',
            message: 'เปลี่ยนชื่อผู้ใช้สำเร็จ',
            isSuccess: true,
            onOk: () {
              Get.back(result: true);
            },
          );
        }
      } else {
        if (mounted) {
          showCustomDialog(
            title: 'เกิดข้อผิดพลาด',
            message: _adminController.errorMessage.value.isNotEmpty
                ? _adminController.errorMessage.value
                : 'ไม่สามารถเปลี่ยนชื่อผู้ใช้ได้ (อาจมีชื่อซ้ำ)',
          );
        }
      }
    } catch (e) {
      debugPrint('Error changing username (admin): $e');
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
          'เปลี่ยนชื่อผู้ใช้',
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
        child: Column(
          children: [
            AdminPageHeader(
              title: 'ชื่อผู้ใช้ใหม่',
              subtitle: 'แก้ไขชื่อที่จะแสดงในระบบ',
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 16),
            AdminCard(
              child: TextField(
                controller: _usernameCtl,
                decoration: const InputDecoration(
                  labelText: 'ชื่อผู้ใช้ใหม่',
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
                onPressed: _isLoading ? null : _changeUsername,
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
                        'บันทึกชื่อผู้ใช้ใหม่',
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
    );
  }
}
