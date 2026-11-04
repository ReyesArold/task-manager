import 'package:flutter/material.dart';
import 'package:myapp/core/app_colors.dart';
import 'package:myapp/core/app_translations.dart';
import 'package:myapp/core/auth_helper.dart';
import 'package:myapp/widgets/glow_background.dart';
import 'package:myapp/widgets/interactive.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSaving = false;
  Set<String> _validUsernames = {};

  @override
  void initState() {
    super.initState();
    _loadValidUsernames();
  }

  Future<void> _loadValidUsernames() async {
    final usernames = await AuthHelper.usernames();
    if (!mounted) return;
    setState(() => _validUsernames = usernames);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _newPasswordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final username = _usernameController.text.trim();
    final newPassword = _newPasswordController.text;
    await AuthHelper.updatePassword(username, newPassword);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppTranslations.of(context).passwordResetSuccess),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop(username);
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppTranslations.of(context);
    return Scaffold(
      backgroundColor: AppColors.scaffold(context),
      appBar: PrimaryAppBar(title: tr.forgotPasswordTitle),
      body: GlowBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: GlassPanel(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              const SizedBox(height: 8),
              Text(
                tr.resetPasswordHeader,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                tr.resetPasswordSubtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: tr.username,
                  prefixIcon: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.blue.withValues(alpha: 0.15),
                    child: const Icon(Icons.person_outline, color: Colors.blue, size: 18),
                  ),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return tr.usernameRequired;
                  if (!_validUsernames.contains(text)) return tr.unknownUsername;
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNew,
                decoration: InputDecoration(
                  labelText: tr.newPassword,
                  hintText: tr.min6Chars,
                  prefixIcon: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.teal.withValues(alpha: 0.15),
                    child: const Icon(Icons.lock_outline, color: Colors.teal, size: 18),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                validator: (value) {
                  final text = value ?? '';
                  if (text.isEmpty) return tr.passwordRequired;
                  if (text.length < 6) return tr.useAtLeast6;
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: tr.confirmPassword,
                  prefixIcon: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.teal.withValues(alpha: 0.15),
                    child: const Icon(Icons.lock_outline, color: Colors.teal, size: 18),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return tr.confirmYourPassword;
                  if (value != _newPasswordController.text) {
                    return tr.passwordsDoNotMatch;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: tr.resetPassword,
                icon: Icons.lock_reset,
                isLoading: _isSaving,
                onPressed: _resetPassword,
              ),
            ],
          ),
        ),
      ),
    ),
  ),
    );
  }
}