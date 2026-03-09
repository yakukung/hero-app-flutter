import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/admin_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/widgets/custom_dialog.dart';
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
      final adminService = Provider.of<AdminService>(context, listen: false);
      final success = await adminService.updateUserUsername(
        widget.userId,
        newUsername,
      );

      if (success) {
        // Refresh admin user list if needed, or just return success
        // Ideally, we should refresh the specific user details in the previous page
        if (mounted) {
          showCustomDialog(
            title: 'สำเร็จ',
            message: 'เปลี่ยนชื่อผู้ใช้สำเร็จ',
            isSuccess: true,
            onOk: () {
              Get.back(result: true); // Return true to indicate success
            },
          );
        }
      } else {
        if (mounted) {
          showCustomDialog(
            title: 'เกิดข้อผิดพลาด',
            message: 'ไม่สามารถเปลี่ยนชื่อผู้ใช้ได้ (อาจมีชื่อซ้ำ)',
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'เปลี่ยนชื่อผู้ใช้ (Admin)',
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
        child: Column(
          children: [
            TextField(
              controller: _usernameCtl,
              decoration: InputDecoration(
                labelText: 'ชื่อผู้ใช้ใหม่',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _changeUsername,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A5DB9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
