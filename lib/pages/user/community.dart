import 'package:flutter/material.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final List<Map<String, dynamic>> mockPosts = [
    {
      "user_name": "Pom Pom",
      "user_avatar": "https://i.redd.it/g9z0a0x25a0b1.jpg",
      "time": "2024-12-24  21:00:00",
      "content":
          "สวัสดีชีตเนื้อหาใหม่วิชาแคลคูลัสเราอัพให้แล้วนะ!!\nกดดูชีตที่ปุ่ม ดูสินค้า ได้เลย",
      "image":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTGJS1Law-9CRpQ0MrMaBPblZdIVt7DFp9NvQ&s",
      "likes": 12,
      "comments": 3,
      "shares": 2,
      "has_product": true,
    },
    {
      "user_name": "Unknown",
      "user_avatar": "assets/images/default/avatar.png",
      "time": "2024-12-24  21:00:00",
      "content":
          "หาคนติววิชาภาษาอังกฤษหน่อยครับ พอดีไม่ค่อยเข้าใจเรื่อง Tense เลย",
      "image": null,
      "likes": 5,
      "comments": 8,
      "shares": 0,
      "has_product": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildCreatePostInput(),
                const SizedBox(height: 32),
                ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: mockPosts.length,
                  itemBuilder: (context, index) {
                    return _buildPostCard(mockPosts[index]);
                  },
                ),
                const SizedBox(height: 140), // Bottom padding
              ],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'สร้างโพสของคุณที่นี่',
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF2A5DB9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.send, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
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
                    post['user_avatar'] != null &&
                        post['user_avatar'].toString().startsWith('http')
                    ? NetworkImage(post['user_avatar'])
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
                      post['user_name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      post['time'],
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
          Text(
            post['content'],
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          if (post['image'] != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                post['image'],
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Actions
          Row(
            children: [
              if (post['has_product'])
                Container(
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
              const Spacer(),
              _buildActionButton(
                icon: Icons.favorite,
                label: '${post['likes']}',
                color: const Color(0xFF2A5DB9),
                textColor: Colors.white,
                isActive: true,
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.chat_bubble_outline,
                label: '${post['comments']}',
                color: Colors.white,
                isActive: false,
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.share,
                label: '${post['shares']}',
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: isActive ? Colors.white : Colors.black54),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
