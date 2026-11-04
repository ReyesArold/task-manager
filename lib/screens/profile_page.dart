import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:myapp/core/app_colors.dart';
import 'package:myapp/core/app_translations.dart';
import 'package:myapp/core/profile_helper.dart';
import 'package:myapp/core/profile_image_helper.dart';
import 'package:myapp/screens/edit_profile_page.dart';
import 'package:myapp/widgets/glow_background.dart';
import 'package:myapp/widgets/interactive.dart';

class ProfilePage extends StatefulWidget {
  final String username;

  const ProfilePage({super.key, required this.username});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _imageFile;
  ProfileData _profile = const ProfileData();
  final _picker = ImagePicker();

  String get _initials => ProfileHelper.initials(_profile.fullName);

  @override
  void initState() {
    super.initState();
    _enableAndroidPhotoPicker();
    _loadImage();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await ProfileHelper.loadProfile(username: widget.username);
    if (!mounted) return;
    setState(() => _profile = data);
  }

  void _enableAndroidPhotoPicker() {
    final implementation = ImagePickerPlatform.instance;
    if (implementation is ImagePickerAndroid) {
      implementation.useAndroidPhotoPicker = true;
    }
  }

  Future<void> _loadImage() async {
    final file = await ProfileImageHelper.getImageFile(widget.username);
    if (!mounted) return;
    setState(() => _imageFile = file);
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;
      await ProfileImageHelper.saveImage(widget.username, picked.path);
      if (!mounted) return;
      setState(() => _imageFile = File(picked.path));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTranslations.of(context).galleryError)),
      );
    }
  }

  Future<void> _openEditProfile() async {
    final updated = await Navigator.of(context).push<ProfileData>(
      MaterialPageRoute(
        builder: (_) => EditProfilePage(profile: _profile),
      ),
    );
    if (updated == null || !mounted) return;
    setState(() => _profile = updated);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppTranslations.of(context).profileUpdated)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppTranslations.of(context);
    return Scaffold(
      backgroundColor: AppColors.scaffold(context),
      appBar: PrimaryAppBar(title: tr.profile),
      body: GlowBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
            const SizedBox(height: 16),
            PressableScale(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue,
                    backgroundImage:
                        _imageFile != null ? FileImage(_imageFile!) : null,
                    child: _imageFile == null
                        ? Text(
                            _initials,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            PressableScale(
              onTap: _pickImage,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.photo_library_outlined,
                    size: 16,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 4),
                  Text(tr.changeProfilePicture,
                      style: const TextStyle(color: Colors.blue)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _profile.fullName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '@${_profile.username}',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 28),
            _buildInfoTile(
              context,
              icon: Icons.person_outline,
              title: tr.fullName,
              value: _profile.fullName,
              accent: Colors.blue,
            ),
            _buildInfoTile(
              context,
              icon: Icons.alternate_email,
              title: tr.username,
              value: _profile.username,
              accent: Colors.purple,
            ),
            _buildInfoTile(
              context,
              icon: Icons.email_outlined,
              title: tr.email,
              value: _profile.email,
              accent: Colors.teal,
            ),
            _buildInfoTile(
              context,
              icon: Icons.phone_outlined,
              title: tr.phone,
              value: _profile.phone,
              accent: Colors.orange,
            ),
            _buildInfoTile(
              context,
              icon: Icons.location_on_outlined,
              title: tr.location,
              value: _profile.location,
              accent: Colors.red,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: tr.editProfile,
              icon: Icons.edit_outlined,
              onPressed: _openEditProfile,
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color accent,
  }) {
    return InteractiveCard(
      accent: accent,
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: accent.withValues(alpha: 0.15),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}