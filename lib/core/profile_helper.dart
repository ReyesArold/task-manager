import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ProfileData {
  const ProfileData({
    this.fullName = 'Arold M. Reyes',
    this.username = 'admin',
    this.email = 'arold.reyes@email.com',
    this.phone = '+1 (555) 123-4567',
    this.location = 'San Francisco, CA',
  });

  final String fullName;
  final String username;
  final String email;
  final String phone;
  final String location;

  ProfileData copyWith({
    String? fullName,
    String? username,
    String? email,
    String? phone,
    String? location,
  }) {
    return ProfileData(
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
    );
  }
}

class ProfileHelper {
  static const _blobKeyPrefix = 'user_profile_';
  static const _kFullName = 'profile_full_name';
  static const _kUsername = 'profile_username';
  static const _kEmail = 'profile_email';
  static const _kPhone = 'profile_phone';
  static const _kLocation = 'profile_location';

  static const _defaults = ProfileData();

  static String _key(String username) => '$_blobKeyPrefix$username';

  static Future<void> saveProfile(ProfileData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key(data.username),
      jsonEncode({
        'fullName': data.fullName,
        'username': data.username,
        'email': data.email,
        'phone': data.phone,
        'location': data.location,
      }),
    );
  }

  static String initials(String fullName) {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0]
        .substring(0, parts[0].length.clamp(0, 2))
        .toUpperCase();
  }

  static Future<ProfileData> loadProfile({String username = 'admin'}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(username));
    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        return ProfileData(
          fullName: map['fullName'] as String? ?? _defaults.fullName,
          username: map['username'] as String? ?? username,
          email: map['email'] as String? ?? _defaults.email,
          phone: map['phone'] as String? ?? _defaults.phone,
          location: map['location'] as String? ?? _defaults.location,
        );
      } catch (_) {
        // Fall through to legacy storage below.
      }
    }
    return ProfileData(
      fullName: prefs.getString(_kFullName) ?? _defaults.fullName,
      username: prefs.getString(_kUsername) ?? username,
      email: prefs.getString(_kEmail) ?? _defaults.email,
      phone: prefs.getString(_kPhone) ?? _defaults.phone,
      location: prefs.getString(_kLocation) ?? _defaults.location,
    );
  }
}