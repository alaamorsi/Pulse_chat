import 'dart:ui'; // Needed for Color class
import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static SharedPreferences? sharedPreferences;

  // Initialize SharedPreferences
  static Future<void> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  // Save boolean value
  static Future<bool?> putBoolean({
    required String key,
    required bool value,
  }) async {
    return await sharedPreferences?.setBool(key, value);
  }

  // Save any type of data (with type checking)
  static Future<bool?> saveData({
    required String key,
    required dynamic value,
  }) async {
    if (value is String) {
      return await sharedPreferences?.setString(key, value);
    } else if (value is int) {
      return await sharedPreferences?.setInt(key, value);
    } else if (value is bool) {
      return await sharedPreferences?.setBool(key, value);
    } else if (value is double) {
      return await sharedPreferences?.setDouble(key, value);
    } else if (value is Color) {
      // Save color as an integer (ARGB value)
      return await sharedPreferences?.setInt(key, value.value);
    } else {
      throw ArgumentError('Unsupported type');
    }
  }

  // Retrieve data
  static dynamic getData({
    required String key,
  }) {
    return sharedPreferences?.get(key);
  }

  // Retrieve Color
  static Color? getColor({
    required String key,
  }) {
    int? colorValue = sharedPreferences?.getInt(key);
    if (colorValue != null) {
      return Color(colorValue); // Convert back to Color
    }
    return null;
  }

  // Remove data by key
  static Future<bool> removeData({
    required String key,
  }) async {
    return await sharedPreferences!.remove(key);
  }

  // Clear all data
  static Future<bool> clear() async {
    return await sharedPreferences!.clear();
  }

  // Reload preferences
  static Future<void> reload() async {
    await sharedPreferences?.reload();
  }
}
