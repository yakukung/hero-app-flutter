import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/post_model.dart';
import 'package:flutter_application_1/pages/user/create_post.dart';
import 'package:flutter_application_1/pages/user/sheet/preview_sheet.dart';
import 'package:flutter_application_1/services/posts_service.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  late Future<List<PostModel>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _refreshPosts();
  }

  void _refreshPosts() {
    setState(() {
      _postsFuture = PostsService.getPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            _refreshPosts();
            await _postsFuture;
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildCreatePostInput(),
                  const SizedBox(height: 32),
                  FutureBuilder<List<PostModel>>(
                    future: _postsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('ไม่พบโพสต์'));
                      }

                      final posts = snapshot.data!;
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          return _buildPostCard(posts[index]);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 140), // Bottom padding
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'คอมมูนิตี้',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'สามารถโพสถามหรือแสดงความคิดเห็นกับผู้ใช้คนอื่นได้',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        Divider(color: Colors.grey[200], thickness: 1),
      ],
    );
  }

  Widget _buildCreatePostInput() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreatePostPage()),
        );
        if (result == true) {
          _refreshPosts();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'สร้างโพสของคุณที่นี่',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF2A5DB9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(PostModel post) {
    // Format timestamp
    final formattedDate = post.createdAt.toString().substring(0, 16);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                backgroundImage:
                    post.author.profileImage != null &&
                        post.author.profileImage!.toString().startsWith('http')
                    ? NetworkImage(post.author.profileImage!)
                    : const NetworkImage(
                            'https://cdn-icons-png.flaticon.com/512/847/847969.png',
                          )
                          as ImageProvider,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.author.username ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'ติดตาม',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.more_vert, color: Colors.black54),
            ],
          ),
          const SizedBox(height: 16),
          // Content
          Text(post.content, style: const TextStyle(fontSize: 14, height: 1.5)),
          // TODO: Display attached sheet or images if any
          // if (post.image != null) ...[
          //   const SizedBox(height: 12),
          //   ClipRRect(
          //     borderRadius: BorderRadius.circular(16),
          //     child: Image.network(
          //       post.image!,
          //       width: double.infinity,
          //       fit: BoxFit.cover,
          //     ),
          //   ),
          // ],
          const SizedBox(height: 16),
          // Actions
          Row(
            children: [
              if (post.sheetId != null)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PreviewSheetPage(sheetId: post.sheetId!),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'ดูสินค้า',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              const Spacer(),
              _buildActionButton(
                icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                label: '${post.likeCount}',
                color: post.isLiked ? const Color(0xFF2A5DB9) : Colors.white,
                textColor: post.isLiked ? Colors.white : Colors.black54,
                isActive: post.isLiked,
                onTap: () async {
                  final success = post.isLiked
                      ? await PostsService.unlikePost(post.id)
                      : await PostsService.likePost(post.id);

                  if (success) {
                    setState(() {
                      _postsFuture.then((posts) {
                        final postIndex = posts.indexWhere(
                          (p) => p.id == post.id,
                        );
                        if (postIndex != -1) {
                          final currentPost = posts[postIndex];
                          posts[postIndex] = currentPost.copyWith(
                            isLiked: !currentPost.isLiked,
                            likeCount: currentPost.isLiked
                                ? currentPost.likeCount - 1
                                : currentPost.likeCount + 1,
                          );
                        }
                        return posts;
                      });
                    });
                  }
                },
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.chat_bubble_outline,
                label: '${post.commentCount}',
                color: Colors.white,
                isActive: false,
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.share,
                label: '${post.shareCount}',
                color: Colors.white,
                isActive: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    bool isActive = false,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : Colors.black54,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : textColor ?? Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
