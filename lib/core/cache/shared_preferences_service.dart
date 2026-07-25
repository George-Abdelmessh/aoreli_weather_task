import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around [SharedPreferences] — the single entry point for
/// reading/writing simple cached values (settings, flags, cached simple
/// values). Tokens/credentials belong in `flutter_secure_storage` instead.
class SharedPreferencesService {
  SharedPreferencesService(this._preferences);

  final SharedPreferences _preferences;

  Future<bool> saveData({required String key, required String value}) {
    return _preferences.setString(key, value);
  }

  String? getData({required String key}) {
    return _preferences.getString(key);
  }

  Future<bool> removeData({required String key}) {
    return _preferences.remove(key);
  }
}
