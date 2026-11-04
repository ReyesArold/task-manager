import 'package:flutter/material.dart';
import 'package:myapp/core/app_colors.dart';
import 'package:myapp/core/app_translations.dart';
import 'package:myapp/core/auth_helper.dart';
import 'package:myapp/core/profile_helper.dart';
import 'package:myapp/widgets/glow_background.dart';
import 'package:myapp/widgets/interactive.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isSaving = false;
  String? _usernameError;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    _usernameError = null;
    setState(() => _isSaving = true);

    final account = UserAccount(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      location: _locationController.text.trim(),
    );

    final error = await AuthHelper.register(account);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _isSaving = false;
        _usernameError = AppTranslations.of(context).usernameTaken;
      });
      return;
    }

    await ProfileHelper.saveProfile(
      ProfileData(
        fullName: account.fullName,
        username: account.username,
        email: account.email,
        phone: account.phone.isEmpty ? '—' : account.phone,
        location: account.location.isEmpty ? '—' : account.location,
      ),
    );
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppTranslations.of(context).accountCreated),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop(account.username);
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppTranslations.of(context);
    return Scaffold(
      backgroundColor: AppColors.scaffold(context),
      appBar: PrimaryAppBar(title: tr.createAccount),
      body: GlowBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: GlassPanel(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.blueAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tr.createAccount,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tr.createAccountSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildField(
                    controller: _fullNameController,
                    icon: Icons.person_outline,
                    label: tr.fullName,
                    color: Colors.blue,
                    textInputAction: TextInputAction.next,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? tr.fullNameRequired
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _usernameController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: tr.username,
                      errorText: _usernameError,
                      prefixIcon: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.purple.withValues(alpha: 0.15),
                        child: const Icon(
                          Icons.alternate_email,
                          color: Colors.purple,
                          size: 18,
                        ),
                      ),
                    ),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) return tr.usernameRequired;
                      if (text.length < 3) return tr.usernameTooShort;
                      if (!RegExp(r'^[a-zA-Z0-9_.]+$').hasMatch(text)) {
                        return tr.usernameInvalid;
                      }
                      return null;
                    },
                    onChanged: (_) {
                      if (_usernameError != null) {
                        setState(() => _usernameError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    controller: _emailController,
                    icon: Icons.email_outlined,
                    label: tr.email,
                    color: Colors.teal,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      if (email.isEmpty) return tr.emailRequired;
                      final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
                      if (!regex.hasMatch(email)) return tr.validEmail;
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    controller: _phoneController,
                    icon: Icons.phone_outlined,
                    label: '${tr.phone} (${tr.optional})',
                    color: Colors.orange,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    validator: null,
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    controller: _locationController,
                    icon: Icons.location_on_outlined,
                    label: '${tr.location} (${tr.optional})',
                    color: Colors.red,
                    textInputAction: TextInputAction.next,
                    validator: null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: tr.password,
                      hintText: tr.min6Chars,
                      prefixIcon: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.indigo.withValues(alpha: 0.15),
                        child: const Icon(
                          Icons.lock_outline,
                          color: Colors.indigo,
                          size: 18,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
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
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _register(),
                    decoration: InputDecoration(
                      labelText: tr.confirmPassword,
                      prefixIcon: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.indigo.withValues(alpha: 0.15),
                        child: const Icon(
                          Icons.lock_outline,
                          color: Colors.indigo,
                          size: 18,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return tr.confirmYourPassword;
                      }
                      if (value != _passwordController.text) {
                        return tr.passwordsDoNotMatch;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: tr.createAccount,
                    icon: Icons.person_add_alt_1,
                    isLoading: _isSaving,
                    onPressed: _register,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        tr.alreadyHaveAccount,
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                      const SizedBox(width: 4),
                      PressableScale(
                        onTap: () => Navigator.of(context).pop(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            tr.login,
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required Color color,
    required String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: CircleAvatar(
          radius: 14,
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
      validator: validator,
    );
  }
}