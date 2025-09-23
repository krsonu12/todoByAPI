import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  TokenStorage(this._prefs);

  final SharedPreferences _prefs;

  static const String _key = 'auth_token';

  String? readToken() => _prefs.getString(_key);

  Future<void> writeToken(String token) async {
    await _prefs.setString(_key, token);
  }

  Future<void> clearToken() async {
    await _prefs.remove(_key);
  }
}

final sharedPrefsProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  final prefs = ref
      .watch(sharedPrefsProvider)
      .maybeWhen(data: (p) => p, orElse: () => null);
  if (prefs == null) {
    throw StateError('SharedPreferences not ready');
  }
  return TokenStorage(prefs);
});
