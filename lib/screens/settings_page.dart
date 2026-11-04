import 'package:flutter/material.dart';
import 'package:myapp/core/app_colors.dart';
import 'package:myapp/core/app_translations.dart';
import 'package:myapp/core/notification_helper.dart';
import 'package:myapp/screens/change_password_page.dart';
import 'package:myapp/core/settings_helper.dart';
import 'package:myapp/widgets/interactive.dart';

class SettingsPage extends StatefulWidget {
  final String username;

  const SettingsPage({super.key, required this.username});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const _languages = ['English', 'Filipino', 'Spanish', 'French'];

  bool _darkMode = false;
  bool _notificationsEnabled = true;
  String _language = 'English';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final dark = await SettingsHelper.isDarkMode();
    final notif = await SettingsHelper.isNotificationsEnabled();
    final lang = await SettingsHelper.getLanguage();
    if (!mounted) return;
    setState(() {
      _darkMode = dark;
      _notificationsEnabled = notif;
      _language = lang;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    setState(() => _darkMode = value);
    await SettingsHelper.setDarkMode(value);
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _notificationsEnabled = value);
    await SettingsHelper.setNotificationsEnabled(value);
    if (value) {
      await NotificationHelper.requestAndroidPermission();
    }
  }

  Future<void> _selectLanguage() async {
    final tr = AppTranslations.of(context);
    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: Text(tr.selectLanguage),
          children: [
            RadioGroup<String>(
              groupValue: _language,
              onChanged: (value) {
                if (value != null) Navigator.of(ctx).pop(value);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final lang in _languages)
                    RadioListTile<String>(
                      title: Text(
                        AppTranslations.languageNameOf(lang),
                      ),
                      value: lang,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
    if (selected == null || selected == _language) return;
    setState(() => _language = selected);
    await SettingsHelper.setLanguage(selected);
  }

  Future<void> _openChangePassword() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ChangePasswordPage(username: widget.username),
      ),
    );
    if (changed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTranslations.of(context).passwordUpdated),
        ),
      );
    }
  }

  void _showPrivacy() {
    final tr = AppTranslations.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(tr.privacy),
          content: Text(tr.privacyBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(tr.ok),
            ),
          ],
        );
      },
    );
  }

  void _showAbout() {
    final tr = AppTranslations.of(context);
    showAboutDialog(
      context: context,
      applicationName: 'TaskManager',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.list_alt, size: 48, color: Colors.blue),
      children: [
        Text(tr.aboutDesc),
        const SizedBox(height: 8),
        Text(tr.builtWithFlutter),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppTranslations.of(context);
    return Scaffold(
      backgroundColor: AppColors.scaffold(context),
      appBar: PrimaryAppBar(title: tr.settings),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            title: tr.general,
            children: [
              _buildSettingsTile(
                icon: Icons.language_outlined,
                title: tr.language,
                subtitle: AppTranslations.languageNameOf(_language),
                accent: Colors.indigo,
                onTap: _selectLanguage,
              ),
              _buildSwitchTile(
                icon: Icons.dark_mode_outlined,
                title: tr.darkMode,
                subtitle: _darkMode ? tr.on : tr.off,
                value: _darkMode,
                accent: Colors.purple,
                onChanged: _toggleDarkMode,
              ),
              _buildSwitchTile(
                icon: Icons.notifications_outlined,
                title: tr.notifications,
                subtitle: _notificationsEnabled ? tr.enabled : tr.disabled,
                value: _notificationsEnabled,
                accent: Colors.teal,
                onChanged: _toggleNotifications,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: tr.account,
            children: [
              _buildSettingsTile(
                icon: Icons.lock_outline,
                title: tr.changePassword,
                accent: Colors.orange,
                onTap: _openChangePassword,
              ),
              _buildSettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: tr.privacy,
                accent: Colors.green,
                onTap: _showPrivacy,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: tr.about,
            children: [
              _buildSettingsTile(
                icon: Icons.info_outline,
                title: tr.about,
                subtitle: '${tr.version} 1.0.0',
                accent: Colors.blue,
                onTap: _showAbout,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary(context),
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow(context),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return PressableScale(
      onTap: onTap,
      child: ListTile(
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: accent.withValues(alpha: 0.15),
          child: Icon(icon, color: accent, size: 18),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: subtitle != null
            ? Text(subtitle, style: const TextStyle(fontSize: 12))
            : null,
        trailing: Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary(context),
        ),
        onTap: null,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Color accent,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: CircleAvatar(
        radius: 16,
        backgroundColor: accent.withValues(alpha: 0.15),
        child: Icon(icon, color: accent, size: 18),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: value,
      activeTrackColor: Colors.blue,
      onChanged: onChanged,
    );
  }
}