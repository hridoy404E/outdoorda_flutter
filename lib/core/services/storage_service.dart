import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService._();

  // Legacy keys
  static const String _tokenKey = 'token';
  static const String _idKey = 'userId';

  // New auth keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenTypeKey = 'token_type';
  static const String _roleKey = 'user_role';
  static const String _lastSyncedFcmTokenKey = 'last_synced_fcm_token';
  static const String _lastSyncedFcmUserIdKey = 'last_synced_fcm_user_id';
  static const String _twoFactorEnabledKey = 'two_factor_enabled';
  static const String _jobDraftKey = 'job_draft';

  static SharedPreferences? _preferences;

  static Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  static bool hasToken() {
    final legacyToken = _preferences?.getString(_tokenKey);
    final accessToken = _preferences?.getString(_accessTokenKey);
    return legacyToken != null || accessToken != null;
  }

  static Future<void> saveToken(String token, String id) async {
    await _preferences?.setString(_tokenKey, token);
    await _preferences?.setString(_idKey, id);
  }

  static Future<void> saveAuthData({
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    String? role,
  }) async {
    if (_preferences == null) return;

    if (accessToken != null) {
      await _preferences!.setString(_accessTokenKey, accessToken);
    }
    if (refreshToken != null) {
      await _preferences!.setString(_refreshTokenKey, refreshToken);
    }
    if (tokenType != null) {
      await _preferences!.setString(_tokenTypeKey, tokenType);
    }
    if (role != null) {
      await _preferences!.setString(_roleKey, role);
    }
  }

  static Future<void> clearAuthData() async {
    if (_preferences == null) return;
    await _preferences!.remove(_accessTokenKey);
    await _preferences!.remove(_refreshTokenKey);
    await _preferences!.remove(_tokenTypeKey);
    await _preferences!.remove(_roleKey);
  }

  static Future<void> logoutUser() async {
    await _preferences?.remove(_tokenKey);
    await _preferences?.remove(_idKey);
    await _preferences?.remove(_lastSyncedFcmTokenKey);
    await _preferences?.remove(_lastSyncedFcmUserIdKey);
    await clearAuthData();
    // Navigate to the login screen
    // Get.offAllNamed('/login');
  }

  static Future<void> saveUserId(String userId) async {
    if (userId.trim().isEmpty) return;
    await _preferences?.setString(_idKey, userId.trim());
  }

  static Future<void> saveFcmSyncMeta({
    required String token,
    required String userId,
  }) async {
    if (_preferences == null) return;
    await _preferences!.setString(_lastSyncedFcmTokenKey, token);
    await _preferences!.setString(_lastSyncedFcmUserIdKey, userId);
  }

  static Future<void> clearFcmSyncMeta() async {
    await _preferences?.remove(_lastSyncedFcmTokenKey);
    await _preferences?.remove(_lastSyncedFcmUserIdKey);
  }

  static Future<void> saveTwoFactorEnabled(bool value, {String? scope}) async {
    if (_preferences == null) return;
    await _preferences!.setBool(_twoFactorStorageKey(scope: scope), value);
  }

  static bool getTwoFactorEnabled({String? scope}) {
    return _preferences?.getBool(_twoFactorStorageKey(scope: scope)) ?? false;
  }

  static String _twoFactorStorageKey({String? scope}) {
    final normalizedScope = scope?.trim().isNotEmpty == true
        ? scope!.trim()
        : _defaultScope();
    return '${_twoFactorEnabledKey}_$normalizedScope';
  }

  static String _defaultScope() {
    final currentUserId = userId?.trim();
    if (currentUserId != null && currentUserId.isNotEmpty) {
      return 'user_$currentUserId';
    }

    final currentRole = role?.trim().toLowerCase();
    if (currentRole != null && currentRole.isNotEmpty) {
      return 'role_$currentRole';
    }

    return 'default';
  }

  static String? get userId => _preferences?.getString(_idKey);

  static String? get token => _preferences?.getString(_tokenKey);

  static String? get accessToken => _preferences?.getString(_accessTokenKey);

  static String? get refreshToken => _preferences?.getString(_refreshTokenKey);

  static String? get tokenType => _preferences?.getString(_tokenTypeKey);

  static String? get role => _preferences?.getString(_roleKey);

  static String? get lastSyncedFcmToken =>
      _preferences?.getString(_lastSyncedFcmTokenKey);

  static String? get lastSyncedFcmUserId =>
      _preferences?.getString(_lastSyncedFcmUserIdKey);

  // ── Job Draft ──────────────────────────────────────────────────────────

  /// Save job draft JSON string to local storage.
  static Future<void> saveJobDraft(String jsonString) async {
    await _preferences?.setString(_jobDraftKey, jsonString);
  }

  /// Retrieve stored job draft JSON, or null if none exists.
  static String? getJobDraft() => _preferences?.getString(_jobDraftKey);

  /// Remove the stored job draft.
  static Future<void> clearJobDraft() async {
    await _preferences?.remove(_jobDraftKey);
  }
}
