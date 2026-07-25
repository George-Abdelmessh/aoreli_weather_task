import 'package:shared_preferences/shared_preferences.dart';

/// A service class to manage data storage using SharedPreferences.
///
/// Provides methods to store, retrieve, and remove simple key-value pairs
/// and map data, as well as clearing all stored data.
class SharedPreferencesService {
  SharedPreferencesService(this._preferences);

  final SharedPreferences _preferences;

  /// Retrieves the value associated with the given [key].
  ///
  /// Returns `null` if the key does not exist.
  dynamic getData({required String key}) {
    return _preferences.get(key);
  }

  /// Saves a value of type
  /// `String`, `int`, `bool`, or `double` to SharedPreferences.
  ///
  /// Returns `true` if the value was successfully saved, otherwise `false`.
  Future<bool> saveData({required String key, required dynamic value}) async {
    if (value is String) {
      return _preferences.setString(key, value);
    }
    if (value is int) {
      return _preferences.setInt(key, value);
    }
    if (value is bool) {
      return _preferences.setBool(key, value);
    }
    // Default to double if none of the above types match
    return _preferences.setDouble(key, value);
  }

  /// Saves multiple key-value pairs from a [Map] to SharedPreferences.
  ///
  /// Returns `true` if all values were saved successfully, otherwise `false`.
  Future<bool> saveMapData({required Map<String, dynamic> data}) async {
    try {
      for (var entry in data.entries) {
        await saveData(key: entry.key, value: entry.value);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Removes the value associated with the given [key].
  ///
  /// Returns `true` if the key was successfully removed, otherwise `false`.
  Future<bool> removeData({required String key}) async {
    return _preferences.remove(key);
  }

  /// Clears all stored data in SharedPreferences.
  ///
  /// Returns `true` if the data was successfully cleared, otherwise `false`.
  Future<bool> clearAllData() async {
    return _preferences.clear();
  }
}
