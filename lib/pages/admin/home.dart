import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/api_connect.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/services/admin_service.dart';
import 'package:flutter_application_1/services/navigation_service.dart';
import 'package:flutter_application_1/widgets/navigation/admin_navbottom.dart';
import 'package:flutter_application_1/widgets/navigation/admin_navbar.dart';
import 'package:flutter_application_1/widgets/layout/main_sidebar.dart';
import 'package:flutter_application_1/pages/admin/user_profile.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  // Ideally these pages would be in separate files
  final List<Widget> _pages = [
    const Center(child: Text('Community Page')),
    const Center(child: Text('Reports Page')),
    const AdminUserListPage(),
  ];

  @override
  void initState() {
    super.initState();
    // Default to Users tab (index 2)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<NavigationService>().currentIndex.value = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    final navService = Get.find<NavigationService>();
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        appBar: const AdminNavbar(),
        drawer: const SideBar(),
        extendBody: true,
        body: _pages[navService.currentIndex.value],
        bottomNavigationBar: const AdminNavBottom(),
      ),
    );
  }
}

class AdminUserListPage extends StatefulWidget {
  const AdminUserListPage({super.key});

  @override
  State<AdminUserListPage> createState() => _AdminUserListPageState();
}

class _AdminUserListPageState extends State<AdminUserListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminService>(context, listen: false).fetchUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminService = Provider.of<AdminService>(context);

    // Filter users locally based on search query
    final filteredUsers = adminService.users.where((user) {
      final query = _searchQuery.toLowerCase();
      final username = (user.username ?? '').toLowerCase();
      final uid = user.id.toLowerCase();
      return username.contains(query) || uid.contains(query);
    }).toList();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'ค้นหาชื่อผู้ใช้ หรือ UID',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2A5DB9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // User List
          Expanded(
            child: adminService.isLoading
                ? const Center(child: CircularProgressIndicator())
                : adminService.errorMessage.isNotEmpty
                ? Center(child: Text(adminService.errorMessage))
                : filteredUsers.isEmpty
                ? const Center(child: Text('ไม่พบข้อมูลผู้ใช้'))
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      left: 24.0,
                      right: 24.0,
                      bottom: 140.0,
                    ),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      return _buildUserCard(filteredUsers[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF), // Matches the light blue in screenshot
        borderRadius: BorderRadius.circular(50), // Fully rounded pill shape
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 55,
            height: 55,
            decoration: const BoxDecoration(
              color: Colors.white,
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
                          Icon(Icons.person, color: Colors.grey[400], size: 30),
                    )
                  : Icon(Icons.person, color: Colors.grey[400], size: 30),
            ),
          ),
          const SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'UID: ${user.id}',
                  style: const TextStyle(
                    fontFamily: 'SukhumvitSet',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'ชื่อผู้ใช้: ${user.username ?? 'ไม่ระบุ'}',
                  style: const TextStyle(
                    fontFamily: 'SukhumvitSet',
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    color: Colors.black,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminUserProfilePage(userId: user.id),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'ดูโปรไฟล์',
                style: TextStyle(
                  fontFamily: 'SukhumvitSet',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
