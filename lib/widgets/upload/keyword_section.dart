import 'package:flutter/material.dart';

/// Keyword input and display widget with add/remove functionality
class KeywordSection extends StatelessWidget {
  final List<String> keywords;
  final VoidCallback onAddKeyword;
  final Function(String) onRemoveKeyword;

  const KeywordSection({
    super.key,
    required this.keywords,
    required this.onAddKeyword,
    required this.onRemoveKeyword,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ...keywords.map((keyword) => _buildKeywordChip(keyword)),
        _buildAddButton(),
      ],
    );
  }

  Widget _buildKeywordChip(String keyword) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 8, top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2A5DB9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            keyword,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => onRemoveKeyword(keyword),
            child: const Icon(Icons.close, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: onAddKeyword,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'เพิ่มคีย์เวิร์ด',
          style: TextStyle(color: Color(0xFF7B7B7C), fontSize: 16),
        ),
      ),
    );
  }

  /// Shows the add keyword dialog
  static Future<String?> showAddDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เพิ่มคีย์เวิร์ด'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'ใส่คีย์เวิร์ด',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context, controller.text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A5DB9),
            ),
            child: const Text('เพิ่ม', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
