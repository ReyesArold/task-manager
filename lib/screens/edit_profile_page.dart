import 'package:flutter/material.dart';
import 'package:myapp/core/app_colors.dart';
import 'package:myapp/core/app_translations.dart';
import 'package:myapp/core/profile_helper.dart';
import 'package:myapp/widgets/interactive.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileData profile;

  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _locationController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.profile.username);
    _fullNameController = TextEditingController(text: widget.profile.fullName);
    _emailController = TextEditingController(text: widget.profile.email);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _locationController = TextEditingController(text: widget.profile.location);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final updated = widget.profile.copyWith(
      username: _usernameController.text.trim(),
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      location: _locationController.text.trim(),
    );
    await ProfileHelper.saveProfile(updated);
    if (!mounted) return;
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppTranslations.of(context);
    return Scaffold(
      backgroundColor: AppColors.scaffold(context),
      appBar: PrimaryAppBar(title: tr.editProfile),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField(
                controller: _usernameController,
                icon: Icons.alternate_email,
                label: tr.username,
                color: Colors.purple,
                validator: (value) => value == null || value.trim().isEmpty
                    ? tr.usernameRequired
                    : null,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _fullNameController,
                icon: Icons.person_outline,
                label: tr.fullName,
                color: Colors.blue,
                validator: (value) => value == null || value.trim().isEmpty
                    ? tr.fullNameRequired
                    : null,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _emailController,
                icon: Icons.email_outlined,
                label: tr.email,
                color: Colors.teal,
                keyboardType: TextInputType.emailAddress,
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
                label: tr.phone,
                color: Colors.orange,
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.trim().isEmpty
                    ? tr.phoneRequired
                    : null,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _locationController,
                icon: Icons.location_on_outlined,
                label: tr.location,
                color: Colors.red,
                validator: (value) => value == null || value.trim().isEmpty
                    ? tr.locationRequired
                    : null,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: tr.save,
                icon: Icons.save_outlined,
                isLoading: _isSaving,
                onPressed: _save,
              ),
            ],
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
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
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