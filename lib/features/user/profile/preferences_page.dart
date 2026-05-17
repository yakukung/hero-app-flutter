import 'package:flutter/material.dart';

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
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildInputSection(
            title: 'คีย์เวิร์ดที่สนใจ',
            controller: _keywordController,
            hintText: 'เช่น calculus, flutter, ชีวะ',
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
          ),
          _TagWrap(
            tags: _preferences.keywords,
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
          const SizedBox(height: 24),
          _buildInputSection(
            title: 'รายวิชาที่สนใจ',
            controller: _subjectController,
            hintText: 'เช่น คณิตศาสตร์, คอมพิวเตอร์',
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
          ),
          _TagWrap(
            tags: _preferences.subjects,
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
          const SizedBox(height: 24),
          SwitchListTile(
            value: _preferences.followedOnly,
            onChanged: (value) => _save(
              UserPreferences(
                keywords: _preferences.keywords,
                subjects: _preferences.subjects,
                followedOnly: value,
              ),
            ),
            title: const Text('ให้ความสำคัญกับคนที่ติดตาม'),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection({
    required String title,
    required TextEditingController controller,
    required String hintText,
    required VoidCallback onAdd,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: 'เพิ่ม',
              onPressed: onAdd,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }
}

class _TagWrap extends StatelessWidget {
  const _TagWrap({required this.tags, required this.onDeleted});

  final List<String> tags;
  final ValueChanged<String> onDeleted;

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 10),
        child: Text('ยังไม่ได้ตั้งค่า', style: TextStyle(color: Colors.grey)),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: tags
            .map(
              (tag) =>
                  InputChip(label: Text(tag), onDeleted: () => onDeleted(tag)),
            )
            .toList(),
      ),
    );
  }
}
