import 'package:flutter/foundation.dart';

import 'package:hero_app_flutter/core/models/post_model.dart';
import 'package:hero_app_flutter/core/services/posts_service.dart';
import 'package:hero_app_flutter/core/session/app_session_coordinator.dart';

typedef LoadPosts = Future<List<PostModel>> Function();
typedef TogglePostLike = Future<bool> Function(String postId);
typedef SharePost = Future<ShareActionResult> Function(String postId);

class CommunityPageController extends ChangeNotifier {
  CommunityPageController({
    AppSessionCoordinator? sessionCoordinator,
    LoadPosts? loadPosts,
    TogglePostLike? likePost,
    TogglePostLike? unlikePost,
    SharePost? sharePost,
  }) : _sessionCoordinator = sessionCoordinator ?? AppSessionCoordinator(),
       _loadPosts = loadPosts ?? PostsService.getPosts,
       _likePost = likePost ?? PostsService.likePost,
       _unlikePost = unlikePost ?? PostsService.unlikePost,
       _sharePost = sharePost ?? PostsService.sharePost;

  final AppSessionCoordinator _sessionCoordinator;
  final LoadPosts _loadPosts;
  final TogglePostLike _likePost;
  final TogglePostLike _unlikePost;
  final SharePost _sharePost;

  List<PostModel> _posts = const [];
  bool _isLoading = true;
  String? _errorMessage;

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _sessionCoordinator.isAuthenticated;
  String get currentUserId => _sessionCoordinator.currentUserId;

  Future<void> loadPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _posts = await _loadPosts();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshPosts() => loadPosts();

  Future<bool> toggleLike(PostModel post) async {
    final success = post.isLiked
        ? await _unlikePost(post.id)
        : await _likePost(post.id);

    if (!success) {
      return false;
    }

    _posts = _posts.map((current) {
      if (current.id != post.id) {
        return current;
      }

      final increment = current.isLiked ? -1 : 1;
      return current.copyWith(
        isLiked: !current.isLiked,
        likeCount: current.likeCount + increment,
      );
    }).toList();
    notifyListeners();
    return true;
  }

  void updateCommentCount({required String postId, required int commentCount}) {
    _posts = _posts.map((post) {
      if (post.id != postId) {
        return post;
      }
      return post.copyWith(commentCount: commentCount);
    }).toList();
    notifyListeners();
  }

  Future<ShareActionResult> registerShare(PostModel post) async {
    final result = await _sharePost(post.id);
    if (result.success && !result.alreadyShared) {
      _posts = _posts.map((current) {
        if (current.id != post.id) {
          return current;
        }
        return current.copyWith(
          shareCount: result.shareCount ?? (current.shareCount + 1),
        );
      }).toList();
      notifyListeners();
    }
    return result;
  }
}
