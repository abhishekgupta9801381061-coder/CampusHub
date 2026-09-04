import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/error_banner.dart';
import '../providers/auth_providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _identifierController = TextEditingController();
  final _answerController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _step = 1; // 1: Lookup identifier, 2: Answer question & set new password
  String? _retrievedSecurityQuestion;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _identifierController.dispose();
    _answerController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _lookupAccount() async {
    if (_identifierController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter your Handle or Roll Number');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(authRepositoryProvider);
      final question = await repo.getSecurityQuestion(_identifierController.text);
      if (question != null) {
        setState(() {
          _retrievedSecurityQuestion = question;
          _step = 2;
        });
      } else {
        setState(() {
          _errorMessage = 'No student account found with this identifier.';
        });
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_answerController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please provide your security answer.');
      return;
    }
    if (_newPasswordController.text.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters.');
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.resetPassword(
        rollNoOrHandle: _identifierController.text,
        answer: _answerController.text,
        newPassword: _newPasswordController.text,
      );

      setState(() {
        _successMessage = 'Password reset successfully! You can now log in.';
      });

      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('AuthException: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Recovery'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.securityCardBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.privacy_tip_outlined, color: AppColors.accentBlue),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'CampusHub uses security questions instead of mandatory SMS or email recovery.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF1E40AF),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (_errorMessage != null) ...[
                    ErrorBanner(
                      message: _errorMessage!,
                      onDismiss: () => setState(() => _errorMessage = null),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (_successMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.success.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _successMessage!,
                              style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (_step == 1) ...[
                    Text(
                      'Find your account',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your registered @handle or university roll number.',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      label: 'Roll No or Handle',
                      hintText: 'e.g. 24BCS10142 or @Abhishek07',
                      controller: _identifierController,
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      text: 'Find Security Question',
                      isLoading: _isLoading,
                      onPressed: _lookupAccount,
                    ),
                  ] else ...[
                    Text(
                      'Answer Security Question',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Question:',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _retrievedSecurityQuestion ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Secret Answer',
                      hintText: 'Your answer provided at registration',
                      controller: _answerController,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'New Password',
                      hintText: 'Minimum 6 characters',
                      controller: _newPasswordController,
                      isPassword: true,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Confirm New Password',
                      hintText: 'Re-enter new password',
                      controller: _confirmPasswordController,
                      isPassword: true,
                      isRequired: true,
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      text: 'Reset Password & Proceed',
                      isLoading: _isLoading,
                      onPressed: _resetPassword,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
