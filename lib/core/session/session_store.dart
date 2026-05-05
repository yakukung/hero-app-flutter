import 'package:get_storage/get_storage.dart';

class SessionStore {
  SessionStore({GetStorage? storage}) : _storage = storage ?? GetStorage();

  static const String uidKey = 'uid';
  static const String tokenKey = 'token';
  static const String refreshTokenKey = 'refresh_token';
  static const String accessTokenExpiresAtKey = 'access_token_expires_at';
  static const String refreshTokenExpiresAtKey = 'refresh_token_expires_at';
  static const String roleNameKey = 'role_name';

  final GetStorage _storage;

  String get uid => _readString(uidKey);
  String get token => _readString(tokenKey);
  String get refreshToken => _readString(refreshTokenKey);
  String get accessTokenExpiresAt => _readString(accessTokenExpiresAtKey);
  String get refreshTokenExpiresAt => _readString(refreshTokenExpiresAtKey);
  String get roleName => _readString(roleNameKey);
  bool get isAccessTokenExpired => _isExpired(read(accessTokenExpiresAtKey));
  bool get isRefreshTokenExpired => _isExpired(read(refreshTokenExpiresAtKey));

  dynamic read(String key) => _storage.read(key);

  void write(String key, dynamic value) => _writeOrRemove(key, value);

  void remove(String key) => _storage.remove(key);

  void writeUid(String value) => write(uidKey, value);

  void writeRoleName(String value) => write(roleNameKey, value);

  void persistTokens(Map<String, dynamic> tokens) {
    write(tokenKey, tokens['access_token']);
    write(refreshTokenKey, tokens['refresh_token']);
    write(accessTokenExpiresAtKey, tokens['access_token_expires_at']);
    write(refreshTokenExpiresAtKey, tokens['refresh_token_expires_at']);
  }

  void clearSession() {
    remove(tokenKey);
    remove(refreshTokenKey);
    remove(accessTokenExpiresAtKey);
    remove(refreshTokenExpiresAtKey);
    remove(uidKey);
    remove(roleNameKey);
  }

  Future<void> eraseAll() => _storage.erase();

  String _readString(String key) => _storage.read(key)?.toString() ?? '';

  void _writeOrRemove(String key, dynamic value) {
    if (value == null) {
      _storage.remove(key);
      return;
    }

    if (value is String && value.isEmpty) {
      _storage.remove(key);
      return;
    }

    _storage.write(key, value);
  }

  bool _isExpired(dynamic value) {
    final expiresAt = _parseExpiresAt(value);
    if (expiresAt == null) {
      return false;
    }
    return !DateTime.now().toUtc().isBefore(expiresAt.toUtc());
  }

  DateTime? _parseExpiresAt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    if (value is num) {
      return _parseEpoch(value);
    }

    final text = value.toString().trim();
    if (text.isEmpty) {
      return null;
    }

    final numericValue = num.tryParse(text);
    if (numericValue != null) {
      return _parseEpoch(numericValue);
    }

    return DateTime.tryParse(text);
  }

  DateTime _parseEpoch(num value) {
    final milliseconds = value > 100000000000
        ? value.toInt()
        : (value * 1000).toInt();
    return DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true);
  }
}
