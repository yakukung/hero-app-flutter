import 'package:flutter_test/flutter_test.dart';

import 'package:hero_app_flutter/core/models/enums.dart';
import 'package:hero_app_flutter/core/models/post_model.dart';
import 'package:hero_app_flutter/core/models/user_model.dart';
import 'package:hero_app_flutter/features/user/community/controllers/community_page_controller.dart';

import '../../../../support/test_app_dependencies.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loadPosts and toggleLike update controller state', () async {
    final dependencies = await createTestAppDependencies(
      'community_controller_test',
    );
    final author = UserModel(
      id: 'user-1',
      username: 'hero',
      email: 'hero@example.com',
      authProvider: AuthProvider.EMAIL_PASSWORD,
      roleId: 'role-user',
      roleName: 'USER',
      point: 0,
      visibleFlag: true,
      statusFlag: StatusFlag.ACTIVE,
      createdAt: DateTime.utc(2026, 1, 1),
      createdBy: 'SYSTEM',
    );
    final post = PostModel(
      id: 'post-1',
      userId: 'user-1',
      content: 'post content',
      likeCount: 0,
      commentCount: 0,
      shareCount: 0,
      author: author,
      visibleFlag: true,
      statusFlag: StatusFlag.ACTIVE,
      createdAt: DateTime.utc(2026, 1, 1),
      createdBy: 'SYSTEM',
    );

    final controller = CommunityPageController(
      sessionCoordinator: dependencies.sessionCoordinator,
      loadPosts: () async => [post],
      likePost: (_) async => true,
      unlikePost: (_) async => true,
    );

    await controller.loadPosts();
    final success = await controller.toggleLike(controller.posts.first);

    expect(controller.posts, hasLength(1));
    expect(success, isTrue);
    expect(controller.posts.first.isLiked, isTrue);
    expect(controller.posts.first.likeCount, 1);
  });
}
