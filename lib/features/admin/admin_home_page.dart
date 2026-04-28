import 'package:flutter/material.dart';
import 'package:hero_app_flutter/constants/app_colors.dart';
import 'package:hero_app_flutter/constants/app_fonts.dart';
import 'package:hero_app_flutter/core/config/api_connect.dart';
import 'package:hero_app_flutter/core/controllers/admin_controller.dart';
import 'package:hero_app_flutter/core/controllers/navigation_controller.dart';
import 'package:hero_app_flutter/core/models/user_model.dart';
import 'package:hero_app_flutter/features/admin/admin_user_profile_page.dart';
import 'package:hero_app_flutter/shared/widgets/layout/main_sidebar.dart';
import 'package:hero_app_flutter/shared/widgets/navigation/admin_navbottom.dart';
import 'package:hero_app_flutter/shared/widgets/navigation/admin_navbar.dart';
import 'package:get/get.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final NavigationController _navigationController =
      Get.find<NavigationController>();

  final List<Widget> _pages = const [
    Center(child: Text('Community Page')),
    Center(child: Text('Reports Page')),
    AdminUserListPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigationController.changeIndex(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        appBar: const AdminNavbar(),
        drawer: const MainSidebar(),
        extendBody: true,
        body: _pages[_navigationController.currentIndex.value],
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
  final AdminController _adminController = Get.find<AdminController>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _adminController.fetchUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final filteredUsers = _adminController.users.where((user) {
        final query = _searchQuery.toLowerCase();
        final username = (user.username ?? '').toLowerCase();
        final uid = user.id.toLowerCase();
        return username.contains(query) || uid.contains(query);
      }).toList();

      return SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Container(
                  padding: const EdgeInsets.only(left: 25),
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
                            hintStyle: TextStyle(color: Colors.grey[700]),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
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
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            if (_adminController.isLoading.value)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_adminController.errorMessage.value.isNotEmpty)
              SliverFillRemaining(
                child: Center(child: Text(_adminController.errorMessage.value)),
              )
            else if (filteredUsers.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text('ไม่พบข้อมูลผู้ใช้')),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 140),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: _buildUserCard(filteredUsers[index]),
                    );
                  }, childCount: filteredUsers.length),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildUserCard(UserModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'UID: ${user.id}',
                  style: const TextStyle(
                    fontFamily: AppFonts.sukhumvit,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'ชื่อผู้ใช้: ${user.username ?? 'ไม่ระบุ'}',
                  style: const TextStyle(
                    fontFamily: AppFonts.sukhumvit,
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
              Get.to(() => AdminUserProfilePage(userId: user.id));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'ดูโปรไฟล์',
                style: TextStyle(
                  fontFamily: AppFonts.sukhumvit,
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
