import 'package:flutter/material.dart';
import 'package:hero_app_flutter/constants/app_fonts.dart';
import 'package:hero_app_flutter/core/config/api_connect.dart';
import 'package:hero_app_flutter/core/controllers/admin_controller.dart';
import 'package:hero_app_flutter/core/controllers/navigation_controller.dart';
import 'package:hero_app_flutter/core/models/enums.dart';
import 'package:hero_app_flutter/core/models/user_model.dart';
import 'package:hero_app_flutter/features/admin/admin_community_moderation_page.dart';
import 'package:hero_app_flutter/features/admin/admin_design.dart';
import 'package:hero_app_flutter/features/admin/admin_moderation_pages.dart';
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
    AdminCommunityModerationPage(),
    AdminReportsDashboardPage(),
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
        backgroundColor: Colors.transparent,
        appBar: const AdminNavbar(),
        drawer: const MainSidebar(),
        extendBody: true,
        body: Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(
                color: AdminColors.background,
                child: _pages[_navigationController.currentIndex.value],
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AdminNavBottom(),
            ),
          ],
        ),
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
  StatusFlag? _statusFilter;

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
        final matchesSearch = username.contains(query) || uid.contains(query);
        final matchesStatus =
            _statusFilter == null || user.statusFlag == _statusFilter;
        return matchesSearch && matchesStatus;
      }).toList();
      final totalUsers = _adminController.users.length;
      final userCountLabel = _searchQuery.trim().isEmpty && _statusFilter == null
          ? 'ผู้ใช้ทั้งหมด $totalUsers รายการ'
          : 'พบ ${filteredUsers.length} จาก $totalUsers รายการ';

      return SafeArea(
        child: RefreshIndicator(
          onRefresh: _adminController.fetchUsers,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AdminPageHeader(
                        title: 'จัดการผู้ใช้',
                        subtitle: userCountLabel,
                        icon: Icons.supervisor_account_outlined,
                      ),
                      const SizedBox(height: 18),
                      AdminCard(
                        padding: const EdgeInsets.fromLTRB(16, 2, 8, 2),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search,
                              color: AdminColors.muted,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                  hintText: 'ค้นหาชื่อผู้ใช้ หรือ UID',
                                  hintStyle: TextStyle(
                                    color: AdminColors.muted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 36,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _statusFilterValues.length + 1,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return _UserFilterChip(
                                label: 'ทั้งหมด',
                                selected: _statusFilter == null,
                                onTap: () =>
                                    setState(() => _statusFilter = null),
                              );
                            }
                            final status = _statusFilterValues[index - 1];
                            return _UserFilterChip(
                              label: _userStatusLabel(status),
                              color: _userStatusColor(status),
                              selected: _statusFilter == status,
                              onTap: () =>
                                  setState(() => _statusFilter = status),
                            );
                          },
                        ),
                      ),
                    ],
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
                  child: _AdminListState(
                    icon: Icons.error_outline,
                    title: 'โหลดผู้ใช้ไม่สำเร็จ',
                    message: _adminController.errorMessage.value,
                  ),
                )
              else if (filteredUsers.isEmpty)
                const SliverFillRemaining(
                  child: _AdminListState(
                    icon: Icons.person_search_outlined,
                    title: 'ไม่พบผู้ใช้',
                    message: 'ลองค้นหาด้วยชื่อผู้ใช้หรือ UID อื่น',
                  ),
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
        ),
      );
    });
  }

  Widget _buildUserCard(UserModel user) {
    final statusColor = _userStatusColor(user.statusFlag);
    final username = user.username?.isNotEmpty == true
        ? user.username!
        : 'ไม่ระบุชื่อ';

    return AdminCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      onTap: () => Get.to(() => AdminUserProfilePage(userId: user.id)),
      child: Row(
        children: [
          _AdminUserAvatar(user: user),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  username,
                  style: const TextStyle(
                    fontFamily: AppFonts.sukhumvit,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AdminColors.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'UID: ${user.id}',
                  style: const TextStyle(
                    fontFamily: AppFonts.sukhumvit,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: AdminColors.muted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AdminStatusPill(
                      label: _userStatusLabel(user.statusFlag),
                      color: statusColor,
                    ),
                    Text(
                      roleLabel(user.roleName),
                      style: const TextStyle(
                        color: AdminColors.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right_rounded,
            color: AdminColors.muted.withValues(alpha: 0.5),
            size: 22,
          ),
        ],
      ),
    );
  }

  String _userStatusLabel(StatusFlag status) {
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

  Color _userStatusColor(StatusFlag status) {
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
}

class _AdminUserAvatar extends StatelessWidget {
  const _AdminUserAvatar({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final profileImage = user.profileImage;
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: AdminColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: profileImage != null && profileImage.isNotEmpty
          ? Image.network(
              profileImage.startsWith('http')
                  ? profileImage
                  : '$apiEndpoint/$profileImage',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.person, color: AdminColors.primary),
            )
          : const Icon(Icons.person, color: AdminColors.primary),
    );
  }
}

class _AdminListState extends StatelessWidget {
  const _AdminListState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: AdminColors.primary),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AdminColors.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _statusFilterValues = [
  StatusFlag.PENDING,
  StatusFlag.ACTIVE,
  StatusFlag.INACTIVE,
  StatusFlag.SUSPENDED,
  StatusFlag.TERMINATED,
];

class _UserFilterChip extends StatelessWidget {
  const _UserFilterChip({
    required this.label,
    this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color? color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? (color ?? AdminColors.primary) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: selected
              ? Border.all(
                  color: (color ?? AdminColors.primary).withValues(alpha: 0.3),
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.sukhumvit,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AdminColors.muted,
          ),
        ),
      ),
    );
  }
}
