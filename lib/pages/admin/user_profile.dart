import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/api_connect.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/models/enums.dart';
import 'package:flutter_application_1/services/admin_service.dart';
import 'package:flutter_application_1/pages/admin/edit_user_profile.dart'; // Import the new page
import 'package:flutter_application_1/widgets/custom_dialog.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class AdminUserProfilePage extends StatefulWidget {
  final String userId;
  const AdminUserProfilePage({super.key, required this.userId});

  @override
  State<AdminUserProfilePage> createState() => _AdminUserProfilePageState();
}

class _AdminUserProfilePageState extends State<AdminUserProfilePage> {
  late Future<UserModel?> _userFuture;

  @override
  void initState() {
    super.initState();
    _refreshUser();
  }

  void _refreshUser() {
    _userFuture = Provider.of<AdminService>(
      context,
      listen: false,
    ).fetchUserById(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'โปรไฟล์ผู้ใช้',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildProfileImage(user),
                const SizedBox(height: 24),
                _buildUserInfo(user),
                const SizedBox(height: 24),
                _buildActionButtons(user),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileImage(UserModel user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: user.profileImage != null && user.profileImage!.isNotEmpty
                ? Image.network(
                    user.profileImage!.startsWith('http')
                        ? user.profileImage!
                        : '$apiEndpoint/${user.profileImage}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.person, color: Colors.grey[400], size: 80),
                  )
                : Icon(Icons.person, color: Colors.grey[400], size: 80),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'UID: ${user.id}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'username: ${user.username ?? 'ไม่ระบุ'}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildActionButtons(UserModel user) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            label: 'แก้ไขข้อมูลส่วนตัว\nผู้ใช้คนนี้',
            color: const Color(0xFFD9E6FF),
            textColor: Colors.black,
            onTap: () async {
              await Get.to(() => AdminEditUserProfilePage(user: user));
              _refreshUser();
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            label: 'แก้ไขสถานะของผู้ใช้คนนี้',
            color: const Color(0xFFFFD9D9),
            textColor: Colors.black,
            onTap: () => _showStatusDialog(context, user),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _showStatusDialog(BuildContext context, UserModel user) {
    StatusFlag selectedStatus = user.statusFlag;

    showCustomDialog(
      title: 'แก้ไขสถานะผู้ใช้',
      message: 'เลือกสถานะที่ต้องการเปลี่ยนสำหรับคุณ ${user.username}',
      isConfirm: true,
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: StatusFlag.values.map((status) {
              return RadioListTile<StatusFlag>(
                title: Text(
                  status.name,
                  style: const TextStyle(
                    fontFamily: 'SukhumvitSet',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                value: status,
                groupValue: selectedStatus,
                activeColor: const Color(0xFF2A5DB9),
                onChanged: (StatusFlag? value) {
                  if (value != null) {
                    setState(() {
                      selectedStatus = value;
                    });
                  }
                },
              );
            }).toList(),
          );
        },
      ),
      onOk: () async {
        final success = await Provider.of<AdminService>(
          context,
          listen: false,
        ).updateUserStatus(user.id, selectedStatus.name);

        if (success) {
          if (mounted) {
            setState(() {
              _refreshUser();
            });
          }
          if (context.mounted) {
            if (success) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'สำเร็จ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'SukhumvitSet',
                          ),
                        ),
                        Text(
                          'เปลี่ยนสถานะเป็น ${selectedStatus.name} เรียบร้อยแล้ว',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'SukhumvitSet',
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: const Color(0xFF2AB950),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'เกิดข้อผิดพลาด',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'SukhumvitSet',
                          ),
                        ),
                        const Text(
                          'ไม่สามารถเปลี่ยนสถานะผู้ใช้ได้',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'SukhumvitSet',
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: const Color(0xFFF92A47),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            }
          }
        }
      },
    );
  }
}
