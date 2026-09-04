import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _skillsController;
  late TextEditingController _interestsController;
  late TextEditingController _whatsappController;
  late TextEditingController _instagramController;
  late TextEditingController _linkedinController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider)!;
    _nameController = TextEditingController(text: user.name);
    _skillsController = TextEditingController(text: user.skills.join(', '));
    _interestsController = TextEditingController(text: user.interests.join(', '));
    _whatsappController = TextEditingController(text: user.whatsappOptional ?? '');
    _instagramController = TextEditingController(text: user.instagramOptional ?? '');
    _linkedinController = TextEditingController(text: user.linkedinOptional ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skillsController.dispose();
    _interestsController.dispose();
    _whatsappController.dispose();
    _instagramController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    setState(() => _isLoading = true);

    final skills = _skillsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final interests = _interestsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final updated = currentUser.copyWith(
      name: _nameController.text.trim(),
      skills: skills,
      interests: interests,
      whatsappOptional: _whatsappController.text.isNotEmpty ? _whatsappController.text.trim() : null,
      instagramOptional: _instagramController.text.isNotEmpty ? _instagramController.text.trim() : null,
      linkedinOptional: _linkedinController.text.isNotEmpty ? _linkedinController.text.trim() : null,
    );

    await ref.read(authNotifierProvider.notifier).updateUser(updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!'), behavior: SnackBarBehavior.floating),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Freshman Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Full Name',
                controller: _nameController,
                isRequired: true,
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Skills (comma separated)',
                hintText: 'Flutter, Python, React, CAD, UI/UX',
                controller: _skillsController,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Interests & Passion Areas',
                hintText: 'AI/ML, Hackathons, Robotics, Open Source',
                controller: _interestsController,
              ),
              const SizedBox(height: 20),
              const Text(
                'Private Contact Information',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text(
                'Stored securely. Only shared when you explicitly generate an Ephemeral Social Bridge link.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'WhatsApp (Optional)',
                hintText: '+91...',
                controller: _whatsappController,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Instagram ID (Optional)',
                hintText: 'username',
                controller: _instagramController,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'LinkedIn ID (Optional)',
                hintText: 'profile-id',
                controller: _linkedinController,
              ),
              const SizedBox(height: 28),
              AppButton(
                text: 'Save Changes',
                isLoading: _isLoading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
