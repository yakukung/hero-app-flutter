import 'package:flutter/material.dart';

import 'package:hero_app_flutter/constants/app_colors.dart';
import 'package:hero_app_flutter/core/session/session_store.dart';
import 'package:hero_app_flutter/core/services/preferences_service.dart';
import 'package:hero_app_flutter/core/services/users_service.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  final PreferencesService _preferencesService = PreferencesService();
  final SessionStore _sessionStore = SessionStore();
  final TextEditingController _keywordController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  late UserPreferences _preferences;

  @override
  void initState() {
    super.initState();
    _preferences = _preferencesService.load();
  }

  @override
  void dispose() {
    _keywordController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _save(UserPreferences preferences) async {
    setState(() => _preferences = preferences);
    await _preferencesService.save(preferences);
    await _syncKeywords(preferences.keywords);
  }

  Future<void> _syncKeywords(List<String> keywords) async {
    final uid = _sessionStore.uid;
    final token = _sessionStore.token;
    if (uid.isEmpty || token.isEmpty) {
      return;
    }

    final response = await UsersService.updateKeyword(
      uid: uid,
      keywords: keywords,
      token: token,
    );
    if (!mounted || response.statusCode == 204 || response.statusCode == 200) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('บันทึกความสนใจในเครื่องแล้ว แต่ซิงก์ไม่สำเร็จ'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('ความสนใจของคุณ'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 20),
            child: Text(
              'ตั้งค่าความสนใจเพื่อรับคำแนะนำชีตที่ตรงกับคุณมากขึ้น',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _buildSectionCard(
            icon: Icons.tag_rounded,
            title: 'คีย์เวิร์ดที่สนใจ',
            subtitle: 'เช่น calculus, flutter, ชีวะ',
            hintText: 'พิมพ์คีย์เวิร์ดแล้วกดเพิ่ม',
            controller: _keywordController,
            tags: _preferences.keywords,
            onAdd: () {
              final value = _keywordController.text.trim();
              if (value.isEmpty) return;
              _keywordController.clear();
              _save(
                UserPreferences(
                  keywords: [..._preferences.keywords, value],
                  subjects: _preferences.subjects,
                  followedOnly: _preferences.followedOnly,
                ),
              );
            },
            onDeleted: (tag) => _save(
              UserPreferences(
                keywords: _preferences.keywords
                    .where((item) => item != tag)
                    .toList(),
                subjects: _preferences.subjects,
                followedOnly: _preferences.followedOnly,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            icon: Icons.menu_book_rounded,
            title: 'รายวิชาที่สนใจ',
            subtitle: 'เช่น คณิตศาสตร์, คอมพิวเตอร์',
            hintText: 'พิมพ์ชื่อวิชาแล้วกดเพิ่ม',
            controller: _subjectController,
            tags: _preferences.subjects,
            onAdd: () {
              final value = _subjectController.text.trim();
              if (value.isEmpty) return;
              _subjectController.clear();
              _save(
                UserPreferences(
                  keywords: _preferences.keywords,
                  subjects: [..._preferences.subjects, value],
                  followedOnly: _preferences.followedOnly,
                ),
              );
            },
            onDeleted: (tag) => _save(
              UserPreferences(
                keywords: _preferences.keywords,
                subjects: _preferences.subjects
                    .where((item) => item != tag)
                    .toList(),
                followedOnly: _preferences.followedOnly,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              secondary: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.group_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              value: _preferences.followedOnly,
              onChanged: (value) => _save(
                UserPreferences(
                  keywords: _preferences.keywords,
                  subjects: _preferences.subjects,
                  followedOnly: value,
                ),
              ),
              title: const Text(
                'ให้ความสำคัญกับคนที่ติดตาม',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                'แสดงเนื้อหาจากคนที่คุณติดตามก่อน',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String hintText,
    required TextEditingController controller,
    required List<String> tags,
    required VoidCallback onAdd,
    required ValueChanged<String> onDeleted,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE7EAF0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE7EAF0)),
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => onAdd(),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                width: 48,
                child: ElevatedButton(
                  onPressed: onAdd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(Icons.add, size: 22),
                ),
              ),
            ],
          ),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags
                  .map(
                    (tag) => Chip(
                      label: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      deleteIcon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Colors.white70,
                      ),
                      onDeleted: () => onDeleted(tag),
                      backgroundColor: AppColors.primary,
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey[400]),
                  const SizedBox(width: 6),
                  Text(
                    'ยังไม่ได้เพิ่ม',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
