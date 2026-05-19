import 'package:flutter/material.dart';
import 'package:hero_app_flutter/core/config/api_connect.dart';
import 'package:hero_app_flutter/core/controllers/admin_controller.dart';
import 'package:hero_app_flutter/core/models/user_model.dart';
import 'package:hero_app_flutter/core/models/enums.dart';
import 'package:hero_app_flutter/features/admin/admin_design.dart';
import 'package:hero_app_flutter/features/admin/admin_edit_user_profile_page.dart'; // Import the new page
import 'package:hero_app_flutter/shared/widgets/custom_dialog.dart';
import 'package:get/get.dart';
import 'package:hero_app_flutter/constants/app_colors.dart';
import 'package:hero_app_flutter/constants/app_fonts.dart';

class AdminUserProfilePage extends StatefulWidget {
  final String userId;
  const AdminUserProfilePage({super.key, required this.userId});

  @override
  State<AdminUserProfilePage> createState() => _AdminUserProfilePageState();
}

class _AdminUserProfilePageState extends State<AdminUserProfilePage> {
  final AdminController _adminController = Get.find<AdminController>();
  late Future<UserModel?> _userFuture;

  @override
  void initState() {
    super.initState();
    _refreshUser();
  }

  void _refreshUser() {
    _userFuture = _adminController.fetchUserById(widget.userId);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        backgroundColor: AdminColors.background,
        surfaceTintColor: AdminColors.background,
        elevation: 0,
        title: const Text(
          'โปรไฟล์ผู้ใช้',
          style: TextStyle(
            fontFamily: AppFonts.sukhumvit,
            color: AdminColors.text,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<UserModel?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('ไม่พบข้อมูลผู้ใช้'));
          }

          final user = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
            child: Column(
              children: [
                _buildProfileSummary(user),
                const SizedBox(height: 18),
                _buildActionButtons(user),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileSummary(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: [
          _buildProfileImage(user),
          const SizedBox(height: 18),
          _buildUserInfo(user),
        ],
      ),
    );
  }

  Widget _buildProfileImage(UserModel user) {
    final statusColor = _statusColor(user.statusFlag);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AdminColors.border, width: 3),
            color: AdminColors.surfaceAlt,
          ),
          child: ClipOval(
            child: user.profileImage != null && user.profileImage!.isNotEmpty
                ? Image.network(
                    user.profileImage!.startsWith('http')
                        ? user.profileImage!
                        : '$apiEndpoint/${user.profileImage}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(
                          Icons.person_rounded,
                          color: AdminColors.muted,
                          size: 60,
                        ),
                  )
                : const Icon(
                    Icons.person_rounded,
                    color: AdminColors.muted,
                    size: 60,
                  ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Icon(
              _statusIcon(user.statusFlag),
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(UserModel user) {
    final username = user.username?.isNotEmpty == true
        ? user.username!
        : 'ไม่ระบุชื่อ';

    return Column(
      children: [
        Text(
          username,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: AppFonts.sukhumvit,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AdminColors.text,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AdminColors.surfaceAlt,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AdminColors.border),
          ),
          child: SelectableText(
            user.id,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppFonts.sukhumvit,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AdminColors.muted,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            AdminStatusPill(
              label: _statusLabel(user.statusFlag),
              color: _statusColor(user.statusFlag),
            ),
            AdminStatusPill(
              label: roleLabel(user.roleName),
              color: AdminColors.primary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(UserModel user) {
    return Column(
      children: [
        _buildActionButton(
          label: 'แก้ไขข้อมูลส่วนตัว',
          icon: Icons.manage_accounts_outlined,
          color: AdminColors.primary,
          onTap: () async {
            await Get.to(() => AdminEditUserProfilePage(user: user));
            if (mounted) {
              setState(_refreshUser);
            }
          },
        ),
        const SizedBox(height: 10),
        _buildActionButton(
          label: 'แก้ไขสถานะผู้ใช้',
          icon: Icons.shield_rounded,
          color: AdminColors.danger,
          onTap: () => _showStatusDialog(context, user),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AdminCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: AppFonts.sukhumvit,
                color: AdminColors.text,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: AdminColors.muted,
            size: 18,
          ),
        ],
      ),
    );
  }

  String _statusLabel(StatusFlag status) {
    switch (status) {
      case StatusFlag.PENDING:
        return 'รอยืนยัน';
      case StatusFlag.ACTIVE:
        return 'ใช้งาน';
      case StatusFlag.INACTIVE:
        return 'ไม่ใช้งาน';
      case StatusFlag.SUSPENDED:
        return 'ระงับชั่วคราว';
      case StatusFlag.TERMINATED:
        return 'ระงับถาวร';
    }
  }

  Color _statusColor(StatusFlag status) {
    switch (status) {
      case StatusFlag.PENDING:
        return AdminColors.warning;
      case StatusFlag.ACTIVE:
        return AdminColors.success;
      case StatusFlag.INACTIVE:
        return AdminColors.muted;
      case StatusFlag.SUSPENDED:
        return AdminColors.danger;
      case StatusFlag.TERMINATED:
        return AdminColors.danger;
    }
  }

  IconData _statusIcon(StatusFlag status) {
    switch (status) {
      case StatusFlag.PENDING:
        return Icons.hourglass_bottom_rounded;
      case StatusFlag.ACTIVE:
        return Icons.check_rounded;
      case StatusFlag.INACTIVE:
        return Icons.visibility_off_rounded;
      case StatusFlag.SUSPENDED:
        return Icons.block_rounded;
      case StatusFlag.TERMINATED:
        return Icons.close_rounded;
    }
  }

  void _showStatusDialog(BuildContext context, UserModel user) {
    StatusFlag selectedStatus = user.statusFlag;

    showCustomDialog(
      title: 'แก้ไขสถานะผู้ใช้',
      message: 'เลือกสถานะที่ต้องการเปลี่ยนสำหรับคุณ ${user.username}',
      isConfirm: true,
      okButtonLabel: 'บันทึก',
      content: StatefulBuilder(
        builder: (context, setState) {
          return RadioGroup<StatusFlag>(
            groupValue: selectedStatus,
            onChanged: (StatusFlag? value) {
              if (value == null) return;
              setState(() {
                selectedStatus = value;
              });
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: StatusFlag.values.map((status) {
                  return RadioListTile<StatusFlag>(
                    title: Text(
                      _statusLabel(status),
                      style: const TextStyle(
                        fontFamily: AppFonts.sukhumvit,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    value: status,
                    activeColor: AppColors.primary,
                  );
              }).toList(),
            ),
          );
        },
      ),
      onOk: () async {
        final success = await _adminController.updateUserStatus(
          user.id,
          selectedStatus.name,
        );

        if (success && mounted) {
          setState(_refreshUser);
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    success ? 'สำเร็จ' : 'เกิดข้อผิดพลาด',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: AppFonts.sukhumvit,
                    ),
                  ),
                  Text(
                    success
                        ? 'เปลี่ยนสถานะเป็น ${_statusLabel(selectedStatus)} เรียบร้อยแล้ว'
                        : 'ไม่สามารถเปลี่ยนสถานะผู้ใช้ได้',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFonts.sukhumvit,
                    ),
                  ),
                ],
              ),
              backgroundColor: success
                  ? const Color(0xFF2AB950)
                  : const Color(0xFFF92A47),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }
}
