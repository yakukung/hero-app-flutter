import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:hero_app_flutter/features/auth/intro_page.dart';
import 'package:hero_app_flutter/features/user/profile/controllers/profile_page_controller.dart';
import 'package:hero_app_flutter/features/user/profile/edit_profile_page.dart';
import 'package:hero_app_flutter/features/user/profile/notifications_page.dart';
import 'package:hero_app_flutter/features/user/profile/preferences_page.dart';
import 'package:hero_app_flutter/features/user/profile/profile_payments_page.dart';
import 'package:hero_app_flutter/features/user/profile/profile_wallet_page.dart';
import 'package:hero_app_flutter/features/user/profile/user_sheets_page.dart';
import 'package:hero_app_flutter/core/models/enums.dart';
import 'package:hero_app_flutter/core/models/post_model.dart';
import 'package:hero_app_flutter/core/services/posts_service.dart';
import 'package:hero_app_flutter/core/services/reports_service.dart';
import 'package:hero_app_flutter/features/user/community/widgets/community_post_card.dart';
import 'package:hero_app_flutter/features/user/community/widgets/comment_sheet.dart';
import 'package:hero_app_flutter/features/user/community/widgets/create_post_prompt.dart';
import 'package:hero_app_flutter/features/user/community/create_post_page.dart';
import 'package:hero_app_flutter/features/user/profile/widgets/profile_action_grid.dart';
import 'package:hero_app_flutter/features/user/profile/widgets/profile_logout_button.dart';
import 'package:hero_app_flutter/features/user/profile/widgets/profile_subscription.dart';
import 'package:hero_app_flutter/features/user/profile/widgets/profile_summary_section.dart';
import 'package:hero_app_flutter/core/services/payment_service.dart';
import 'package:hero_app_flutter/features/user/sheet/preview_sheet_page.dart';
import 'package:hero_app_flutter/shared/widgets/custom_dialog.dart';
import 'package:hero_app_flutter/shared/widgets/upload/upload_progress_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.controller});

  final ProfilePageController? controller;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late final ProfilePageController _controller;
  late final TabController _tabController;
  final ImagePicker _picker = ImagePicker();

  bool get _ownsController => widget.controller == null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _controller = widget.controller ?? ProfilePageController();
    _controller.loadPosts();
    _controller.loadSharedPosts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image == null) {
      return;
    }

    UploadProgressDialog.show(stateNotifier: _controller.uploadStateNotifier);
    await _controller.uploadProfileImage(File(image.path));
  }

  Future<void> _showLogoutConfirmation() async {
    await showCustomDialog(
      title: 'ยืนยันออกจากระบบ',
      message: 'คุณต้องการออกจากระบบใช่ไหม?',
      isConfirm: true,
      isDanger: true,
      okButtonLabel: 'ออกจากระบบ',
      onOk: () async {
        await _controller.logout();
        Get.offAll(() => const IntroPage());
      },
    );
  }

  Future<void> _openCreatePostPage() async {
    final result = await Get.to(() => const CreatePostPage());
    if (result == true) {
      _controller.loadPosts();
    }
  }

  void _openUserSheets() {
    final validationMessage = _controller.validateUserSheetsAccess();
    if (validationMessage != null) {
      showCustomDialog(title: 'ไม่พบข้อมูลผู้ใช้', message: validationMessage);
      return;
    }

    Get.to(() => UserSheetsPage(userId: _controller.appController.uid));
  }

  void _showSubscriptionPackages() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          ProfileSubscription(fetchPlans: () => PaymentService.fetchPlans()),
    );
  }

  String _formatPostDate2(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/${local.year}  $hour:$minute';
  }

  Future<void> _toggleSharePost(
    PostModel post,
    ValueNotifier<List<PostModel>> notifier,
  ) async {
    final result = post.isShared
        ? await PostsService.unsharePost(post.id)
        : await PostsService.sharePost(post.id);
    if (result.success) {
      final list = notifier.value;
      if (result.removed) {
        notifier.value = list.where((p) => p.id != post.id).toList();
      } else {
        final updated = post.copyWith(
          isShared: true,
          shareCount: result.shareCount ?? post.shareCount + 1,
        );
        final index = list.indexWhere((p) => p.id == post.id);
        if (index != -1) {
          final newList = [...list];
          newList[index] = updated;
          notifier.value = newList;
        }
      }
    }
  }

  Future<void> _toggleLikePost(
    PostModel post,
    ValueNotifier<List<PostModel>> notifier,
  ) async {
    final success = post.isLiked
        ? await PostsService.unlikePost(post.id)
        : await PostsService.likePost(post.id);
    if (success) {
      final updated = post.copyWith(
        isLiked: !post.isLiked,
        likeCount: post.likeCount + (post.isLiked ? -1 : 1),
      );
      final list = notifier.value;
      final index = list.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        final newList = [...list];
        newList[index] = updated;
        notifier.value = newList;
      }
    }
  }

  Future<void> _openComments(PostModel post) async {
    final currentUserId = _controller.appController.uid;
    if (currentUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเข้าสู่ระบบเพื่อแสดงความคิดเห็น')),
      );
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return CommentSheet(
          post: post,
          currentUserId: currentUserId,
          onCommentCountChanged: (count) {},
        );
      },
    );
  }

  void _showOwnPostOptions(
    PostModel post,
    ValueNotifier<List<PostModel>> postsNotifier,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              _OptionTile(
                icon: Icons.edit_outlined,
                label: 'แก้ไขโพสต์',
                onTap: () {
                  Get.back();
                  Get.to(() => CreatePostPage(
                    postId: post.id,
                    initialContent: post.content,
                  ));
                },
              ),
              _OptionTile(
                icon: Icons.delete_outline,
                label: 'ลบโพสต์',
                color: const Color(0xFFC62828),
                onTap: () {
                  Get.back();
                  showCustomDialog(
                    title: 'ลบโพสต์',
                    message: 'คุณแน่ใจหรือไม่ว่าต้องการลบโพสต์นี้?',
                    isConfirm: true,
                    isDanger: true,
                    okButtonLabel: 'ลบ',
                    onOk: () async {
                      final success = await PostsService.deletePost(post.id);
                      if (!mounted) return;
                      if (success) {
                        postsNotifier.value = postsNotifier.value
                            .where((p) => p.id != post.id)
                            .toList();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ลบโพสต์แล้ว')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ไม่สามารถลบโพสต์ได้')),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportPost(PostModel post) {
    final currentUserId = _controller.appController.uid;
    if (currentUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเข้าสู่ระบบก่อนรายงานโพสต์')),
      );
      return;
    }

    final detailController = TextEditingController();
    final reportTypes = ReportType.forTable('posts');
    var selectedType = reportTypes.first;

    showCustomDialog(
      title: 'รายงานโพสต์',
      message: 'ระบุเหตุผลที่ต้องการรายงาน',
      isConfirm: true,
      okButtonLabel: 'ส่งรายงาน',
      isDanger: true,
      content: StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(14),
              ),
              child: DropdownButtonFormField<ReportType>(
                isExpanded: true,
                initialValue: selectedType,
                decoration: const InputDecoration(
                  labelText: 'เหตุผล',
                  border: InputBorder.none,
                ),
                items: reportTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.displayName),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedType = value);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: detailController,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'รายละเอียดเพิ่มเติม',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
      onOk: () async {
        final result = await ReportsService.submitReport(
          referenceId: post.id,
          referenceTable: 'posts',
          reportType: selectedType,
          content: detailController.text.trim(),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.data == true
                  ? 'ส่งรายงานแล้ว'
                  : 'ระบบรายงานยังไม่พร้อมใช้งาน',
            ),
          ),
        );
      },
    );
  }

  void _openPayments() {
    Get.to(() => const ProfilePaymentsPage());
  }

  void _openWallet() {
    Get.to(
      () => ProfileWalletPage(currentWallet: _controller.appController.wallet),
    );
  }

  Widget _buildPostsTabContent({
    required ValueNotifier<bool> isLoadingNotifier,
    required ValueNotifier<List<PostModel>> postsNotifier,
    void Function(PostModel, ValueNotifier<List<PostModel>>)? onShareTap,
  }) {
    return ValueListenableBuilder<bool>(
      valueListenable: isLoadingNotifier,
      builder: (context, isLoading, _) {
        return ValueListenableBuilder<List<PostModel>>(
          valueListenable: postsNotifier,
          builder: (context, posts, _) {
            if (isLoading) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (posts.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'ยังไม่มีโพสต์',
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ),
              );
            }

            return Column(
              children: posts
                  .take(5)
                  .map(
                    (post) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CommunityPostCard(
                        post: post,
                        formattedDate: _formatPostDate2(post.createdAt),
                        onUserTap: () {},
                        onReportTap: () {
                          if (post.userId == _controller.appController.uid) {
                            _showOwnPostOptions(post, postsNotifier);
                          } else {
                            _showReportPost(post);
                          }
                        },
                        onSheetTap: post.sheetId == null
                            ? null
                            : () => Get.to(
                                () => PreviewSheetPage(sheetId: post.sheetId!),
                              ),
                        onLikeTap: () => _toggleLikePost(post, postsNotifier),
                        onCommentTap: () => _openComments(post),
                        onShareTap: onShareTap == null
                            ? null
                            : () => onShareTap(post, postsNotifier),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        );
      },
    );
  }

  void _openPreferences() {
    Get.to(() => const PreferencesPage());
  }

  void _openNotifications() {
    Get.to(() => const NotificationsPage());
  }

  @override
  Widget build(BuildContext context) {
    final appController = _controller.appController;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(
        () => RefreshIndicator(
          onRefresh: _controller.refresh,
          child: ListView(
            children: [
              const SizedBox(height: 32),
              ProfileSummarySection(
                uid: appController.uid,
                profileImage: appController.profileImage,
                username: appController.username,
                email: appController.email,
                followersCount: appController.followersCount,
                followingsCount: appController.followingsCount,
                isPremium:
                    appController.subscriptionStatus.value?.isPremium ?? false,
                expiresAt:
                    appController.subscriptionStatus.value?.expiresAt,
                onEditAvatar: _pickProfileImage,
              ),
              const SizedBox(height: 24),
              ProfileActionGrid(
                wallet: appController.wallet,
                onEditProfile: () {
                  Get.to(() => const EditProfilePage());
                },
                onShowSubscriptions: _showSubscriptionPackages,
                onOpenUserSheets: _openUserSheets,
                onOpenPayments: _openPayments,
                onOpenWallet: _openWallet,
                onOpenPreferences: _openPreferences,
                onOpenNotifications: _openNotifications,
              ),
              // const SizedBox(height: 12),
              // ProfileLogoutButton(onPressed: _showLogoutConfirmation),
              const SizedBox(height: 18),
              // Text(
              //   'กิจกรรมล่าสุด',
              //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              // ).paddingSymmetric(horizontal: 20),
              // const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CreatePostPrompt(onTap: _openCreatePostPage),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: const Color(0xFF1A1A1A),
                    unselectedLabelColor: Colors.grey,
                    labelStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    dividerColor: Colors.transparent,
                    splashBorderRadius: BorderRadius.circular(999),
                    tabs: const [
                      Tab(text: 'โพสต์ของฉัน'),
                      Tab(text: 'โพสต์ที่แชร์'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  child: IndexedStack(
                    index: _tabController.index,
                    children: [
                      _buildPostsTabContent(
                        isLoadingNotifier: _controller.isLoadingPosts,
                        postsNotifier: _controller.userPosts,
                      ),
                      _buildPostsTabContent(
                        isLoadingNotifier: _controller.isLoadingSharedPosts,
                        postsNotifier: _controller.sharedPosts,
                        onShareTap: _toggleSharePost,
                      ),
                    ],
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

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? Colors.black87;
    return ListTile(
      leading: Icon(icon, color: themeColor),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: themeColor,
        ),
      ),
      onTap: onTap,
    );
  }
}
