import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileImageHelper {
  static const String _key = 'profile_image_path';
  static const String _prefix = 'profile_image_';

  static String _keyFor(String username) => '$_prefix$username';

  static Future<void> saveImage(String username, String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFor(username), path);
  }

  static Future<String?> getImagePath(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final perUser = prefs.getString(_keyFor(username));
    if (perUser != null) return perUser;
    if (username == 'admin') return prefs.getString(_key);
    return null;
  }

  static Future<File?> getImageFile(String username) async {
    final path = await getImagePath(username);
    if (path == null) return null;
    final file = File(path);
    if (await file.exists()) return file;
    return null;
  }

  static Future<void> removeImage(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFor(username));
  }
}
