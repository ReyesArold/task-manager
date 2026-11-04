import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsHelper {
  static const _kDarkMode = 'settings_dark_mode';
  static const _kNotifications = 'settings_notifications';
  static const _kLanguage = 'settings_language';
  static const _kPassword = 'settings_password';

  static final ValueNotifier<bool> darkMode = ValueNotifier(true);
  static final ValueNotifier<String> language = ValueNotifier('English');
  static final ValueNotifier<bool> notifications = ValueNotifier(true);

  static Future<void> init() async {
    darkMode.value = await isDarkMode();
    language.value = await getLanguage();
    notifications.value = await isNotificationsEnabled();
  }

  static Future<bool> isDarkMode() => _getBool(_kDarkMode, true);
  static Future<void> setDarkMode(bool value) async {
    darkMode.value = value;
    await _setBool(_kDarkMode, value);
  }

  static Future<bool> isNotificationsEnabled() => _getBool(_kNotifications, true);
  static Future<void> setNotificationsEnabled(bool value) async {
    notifications.value = value;
    await _setBool(_kNotifications, value);
  }

  static Future<bool> notificationsAllowed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kNotifications) ?? true;
  }

  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kLanguage) ?? 'English';
  }

  static Future<void> setLanguage(String value) async {
    language.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLanguage, value);
  }

  static Future<String?> getPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kPassword);
  }

  static Future<void> setPassword(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPassword, value);
  }

  static Future<bool> _getBool(String key, bool fallback) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? fallback;
  }

  static Future<void> _setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }
}