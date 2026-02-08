import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/api_connect.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/services/admin_service.dart';
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
          onPressed: () => Navigator.pop(context),
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

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Header: Avatar + Info
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child:
                            user.profileImage != null &&
                                user.profileImage!.isNotEmpty
                            ? Image.network(
                                user.profileImage!.startsWith('http')
                                    ? user.profileImage!
                                    : '$apiEndpoint/${user.profileImage}',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                      Icons.person,
                                      color: Colors.grey[400],
                                      size: 80,
                                    ),
                              )
                            : Icon(
                                Icons.person,
                                color: Colors.grey[400],
                                size: 80,
                              ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    // UID + Name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'UID ${user.id}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user.username ?? 'ไม่ระบุ',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 60),

                // Buttons Section
                Row(
                  children: [
                    // Edit Info Button
                    Expanded(
                      child: _buildActionButton(
                        label: 'แก้ไขข้อมูลส่วนตัว\nผู้ใช้คนนี้',
                        color: const Color(0xFFD9E6FF), // Light blue
                        textColor: Colors.black,
                        onTap: () {
                          // TODO: Implement Edit
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Suspend Button
                    Expanded(
                      child: _buildActionButton(
                        label: 'ระงับบัญชีผู้ใช้คนนี้',
                        color: const Color(0xFFFFD9D9), // Light red/pink
                        textColor: Colors.black,
                        onTap: () {
                          // TODO: Implement Suspend
                          _showSuspendDialog(context, user);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
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
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
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

  void _showSuspendDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ระงับบัญชี'),
        content: Text('คุณต้องการระงับบัญชีคุณ ${user.username} ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Call Suspend API
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ระงับบัญชีเรียบร้อยแล้ว')),
              );
            },
            child: const Text('ยืนยัน', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
