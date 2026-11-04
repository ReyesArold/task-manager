import 'dart:io';

import 'package:flutter/material.dart';
import 'package:myapp/core/app_translations.dart';
import 'package:myapp/core/profile_helper.dart';
import 'package:myapp/core/profile_image_helper.dart';
import 'package:myapp/core/task_filter.dart';
import 'package:myapp/screens/login_page.dart';
import 'package:myapp/screens/profile_page.dart';
import 'package:myapp/screens/settings_page.dart';
import 'package:myapp/widgets/glow_background.dart';
import 'package:myapp/widgets/interactive.dart';

class AppDrawer extends StatelessWidget {
  final String username;
  final ValueChanged<TaskFilter?>? onSelectFilter;

  const AppDrawer({super.key, required this.username, this.onSelectFilter});

  @override
  Widget build(BuildContext context) {
    final tr = AppTranslations.of(context);
    return Drawer(
      backgroundColor: Colors.transparent,
      child: GlowBackground(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            currentAccountPicture: FutureBuilder<ProfileData>(
              future: ProfileHelper.loadProfile(username: username),
              builder: (context, snapshot) {
                final name = snapshot.data?.fullName ?? 'Arold M. Reyes';
                return FutureBuilder<File?>(
                  future: ProfileImageHelper.getImageFile(username),
                  builder: (context, imageSnap) {
                    final file = imageSnap.data;
                    return CircleAvatar(
                      backgroundImage: file != null ? FileImage(file) : null,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      child: file == null
                          ? Text(
                              ProfileHelper.initials(name),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    );
                  },
                );
              },
            ),
            accountName: FutureBuilder<ProfileData>(
              future: ProfileHelper.loadProfile(username: username),
              builder: (context, snapshot) {
                final name = snapshot.data?.fullName ?? 'Arold M. Reyes';
                return Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            accountEmail: Text(
              username,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
          _DrawerTile(
            icon: Icons.dashboard_outlined,
            label: tr.dashboard,
            selected: true,
            onTap: () {
              final nav = Navigator.of(context);
              nav.pop();
              onSelectFilter?.call(null);
            },
          ),
          const Divider(),
          _DrawerTile(
            icon: TaskFilter.completed.icon,
            label: tr.completed,
            color: TaskFilter.completed.color,
            onTap: () {
              final nav = Navigator.of(context);
              nav.pop();
              onSelectFilter?.call(TaskFilter.completed);
            },
          ),
          _DrawerTile(
            icon: TaskFilter.overdue.icon,
            label: tr.overdue,
            color: TaskFilter.overdue.color,
            onTap: () {
              final nav = Navigator.of(context);
              nav.pop();
              onSelectFilter?.call(TaskFilter.overdue);
            },
          ),
          _DrawerTile(
            icon: TaskFilter.today.icon,
            label: tr.today,
            color: TaskFilter.today.color,
            onTap: () {
              final nav = Navigator.of(context);
              nav.pop();
              onSelectFilter?.call(TaskFilter.today);
            },
          ),
          const Divider(),
          _DrawerTile(
            icon: Icons.person_outline,
            label: tr.profile,
            onTap: () {
              final nav = Navigator.of(context);
              nav.pop();
              nav.push(
                MaterialPageRoute(
                  builder: (_) => ProfilePage(username: username),
                ),
              );
            },
          ),
          _DrawerTile(
            icon: Icons.settings_outlined,
            label: tr.settings,
            onTap: () {
              final nav = Navigator.of(context);
              nav.pop();
              nav.push(
                MaterialPageRoute(
                  builder: (_) => SettingsPage(username: username),
                ),
              );
            },
          ),
          const Divider(),
          _DrawerTile(
            icon: Icons.logout,
            label: tr.logout,
            color: Colors.red,
            onTap: () {
              final nav = Navigator.of(context);
              nav.pop();
              showDialog<void>(
                context: context,
                builder: (ctx) {
                  final dtr = AppTranslations.of(ctx);
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Text(dtr.logout),
                    content: Text(dtr.logoutConfirm),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(dtr.cancel),
                      ),
                      TextButton(
                        onPressed: () {
                          final dialogNav = Navigator.of(ctx);
                          dialogNav.pop();
                          dialogNav.pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                            (route) => false,
                          );
                        },
                        child: Text(
                          dtr.logout,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.label,
    this.selected = false,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tileColor = color ?? Colors.blue;
    return PressableScale(
      onTap: onTap,
      child: ListTile(
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: selected
              ? Colors.blue.withValues(alpha: 0.15)
              : tileColor.withValues(alpha: 0.08),
          child: Icon(icon, color: tileColor, size: 18),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: color,
          ),
        ),
        selected: selected,
        selectedTileColor: Colors.blue.withValues(alpha: 0.1),
        onTap: null,
      ),
    );
  }
}