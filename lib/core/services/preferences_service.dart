import 'package:get_storage/get_storage.dart';

class UserPreferences {
  const UserPreferences({
    this.keywords = const [],
    this.subjects = const [],
    this.followedOnly = false,
  });

  final List<String> keywords;
  final List<String> subjects;
  final bool followedOnly;

  bool get isEmpty => keywords.isEmpty && subjects.isEmpty && !followedOnly;
}

class PreferencesService {
  PreferencesService({GetStorage? storage})
    : _storage = storage ?? GetStorage();

  static const _keywordsKey = 'preference_keywords';
  static const _subjectsKey = 'preference_subjects';
  static const _followedOnlyKey = 'preference_followed_only';

  final GetStorage _storage;

  UserPreferences load() {
    return UserPreferences(
      keywords: _readStringList(_keywordsKey),
      subjects: _readStringList(_subjectsKey),
      followedOnly: _storage.read(_followedOnlyKey) == true,
    );
  }

  Future<void> save(UserPreferences preferences) async {
    await _storage.write(_keywordsKey, preferences.keywords);
    await _storage.write(_subjectsKey, preferences.subjects);
    await _storage.write(_followedOnlyKey, preferences.followedOnly);
  }

  List<String> _readStringList(String key) {
    final value = _storage.read(key);
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return const [];
  }
}
