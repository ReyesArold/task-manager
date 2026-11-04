import 'dart:convert';

import 'package:myapp/core/profile_helper.dart';
import 'package:myapp/core/settings_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserAccount {
  final String username;
  final String password;
  final String fullName;
  final String email;
  final String phone;
  final String location;
  final DateTime createdAt;

  UserAccount({
    required this.username,
    required this.password,
    required this.fullName,
    this.email = '',
    this.phone = '',
    this.location = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'username': username,
        'password': password,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'location': location,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory UserAccount.fromMap(Map<String, dynamic> map) => UserAccount(
        username: map['username'] as String,
        password: map['password'] as String,
        fullName: map['fullName'] as String? ?? '',
        email: map['email'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
        location: map['location'] as String? ?? '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          (map['createdAt'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
        ),
      );
}

class AuthHelper {
  static const _kUsers = 'auth_users';
  static const _defaultPassword = 'admin123';

  static Future<List<Map<String, dynamic>>> _all() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kUsers);
    if (raw == null || raw.isEmpty) return [];
    try {
      return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _write(List<Map<String, dynamic>> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUsers, jsonEncode(users));
  }

  static bool _sameName(String a, String b) =>
      a.trim().toLowerCase() == b.trim().toLowerCase();

  static Future<bool> usernameExists(String username) async {
    final users = await _all();
    return users.any((u) => _sameName(u['username'] as String, username));
  }

  /// All valid usernames that can be used to log in, including the
  /// legacy default profile username.
  static Future<Set<String>> usernames() async {
    final users = await _all();
    final set = users.map((u) => u['username'] as String).toSet();
    final profile = await ProfileHelper.loadProfile();
    set.add(profile.username);
    return set;
  }

  /// Registers a new account. Returns `null` on success or the translation
  /// key of the error (e.g. `usernameTaken`).
  static Future<String?> register(UserAccount account) async {
    if (await usernameExists(account.username)) return 'usernameTaken';
    final users = await _all();
    users.add(account.toMap());
    await _write(users);
    return null;
  }

  static Future<bool> login(String username, String password) async {
    final users = await _all();
    for (final u in users) {
      if (_sameName(u['username'] as String, username)) {
        return u['password'] == password;
      }
    }
    final profile = await ProfileHelper.loadProfile();
    final stored = await SettingsHelper.getPassword();
    return _sameName(profile.username, username) &&
        password == (stored ?? _defaultPassword);
  }

  static Future<bool> verifyPassword(String username, String password) async {
    final users = await _all();
    for (final u in users) {
      if (_sameName(u['username'] as String, username)) {
        return u['password'] == password;
      }
    }
    final stored = await SettingsHelper.getPassword();
    return password == (stored ?? _defaultPassword);
  }

  static Future<void> updatePassword(String username, String password) async {
    final users = await _all();
    var updated = false;
    for (var i = 0; i < users.length; i++) {
      if (_sameName(users[i]['username'] as String, username)) {
        users[i]['password'] = password;
        updated = true;
        break;
      }
    }
    if (updated) {
      await _write(users);
    } else {
      await SettingsHelper.setPassword(password);
    }
  }
}