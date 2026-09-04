import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/error_banner.dart';
import '../providers/auth_providers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  final bool initialIsSignUp;

  const AuthScreen({
    super.key,
    this.initialIsSignUp = false,
  });

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  late bool _isSignUp;

  // Login controllers
  final _loginFormKey = GlobalKey<FormState>();
  final _loginIdentifierController = TextEditingController(text: '@Abhishek07');
  final _loginPasswordController = TextEditingController(text: 'Password123');

  // Sign up controllers
  final _signUpFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rollController = TextEditingController();
  final _handleController = TextEditingController(text: '@');
  final _signUpPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _securityAnswerController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _instagramController = TextEditingController();
  final _linkedinController = TextEditingController();

  String _selectedBranch = AppConstants.branches.first;
  String _selectedHostel = AppConstants.hostels.first;
  String _selectedSecurityQuestion = AppConstants.securityQuestions.first;
  bool _allowPromotionalConsent = true;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.initialIsSignUp;
  }

  @override
  void dispose() {
    _loginIdentifierController.dispose();
    _loginPasswordController.dispose();
    _nameController.dispose();
    _rollController.dispose();
    _handleController.dispose();
    _signUpPasswordController.dispose();
    _confirmPasswordController.dispose();
    _securityAnswerController.dispose();
    _whatsappController.dispose();
    _instagramController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authNotifierProvider.notifier).login(
            _loginIdentifierController.text,
            _loginPasswordController.text,
          );
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('AuthException: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSignUp() async {
    if (!_signUpFormKey.currentState!.validate()) return;

    if (_signUpPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authNotifierProvider.notifier).register(
            name: _nameController.text,
            handle: _handleController.text,
            rollNo: _rollController.text,
            branch: _selectedBranch,
            hostel: _selectedHostel,
            password: _signUpPasswordController.text,
            securityQuestion: _selectedSecurityQuestion,
            securityAnswer: _securityAnswerController.text,
            whatsappOptional: _whatsappController.text.isNotEmpty ? _whatsappController.text : null,
            instagramOptional: _instagramController.text.isNotEmpty ? _instagramController.text : null,
            linkedinOptional: _linkedinController.text.isNotEmpty ? _linkedinController.text : null,
            allowPromotionalConsent: _allowPromotionalConsent,
          );
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('AuthException: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Brand Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'CampusHub',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.primary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Exclusive Private Freshmen Network',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Main Card
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
                        width: 1,
                      ),
                      boxShadow: isDark
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Segmented Switch Tab (matching user screenshot)
                        Center(
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildTabButton(
                                  label: 'Login',
                                  icon: Icons.login_rounded,
                                  isSelected: !_isSignUp,
                                  onTap: () {
                                    setState(() {
                                      _isSignUp = false;
                                      _errorMessage = null;
                                    });
                                  },
                                ),
                                _buildTabButton(
                                  label: 'Sign Up',
                                  icon: Icons.person_add_alt_1_rounded,
                                  isSelected: _isSignUp,
                                  onTap: () {
                                    setState(() {
                                      _isSignUp = true;
                                      _errorMessage = null;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Error Banner
                        if (_errorMessage != null) ...[
                          ErrorBanner(
                            message: _errorMessage!,
                            onDismiss: () => setState(() => _errorMessage = null),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Form Section
                        if (!_isSignUp) _buildLoginForm() else _buildSignUpForm(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  // Privacy Assurance Note
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 14,
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Zero phone & room number policy',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.surfaceDark : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected && !isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? (isDark ? Colors.white : AppColors.primary)
                  : (isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? Colors.white : AppColors.primary)
                    : (isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            label: 'Roll No or Handle',
            hintText: 'e.g. 24BCS10142 or @Abhishek07',
            controller: _loginIdentifierController,
            validator: (v) => InputValidators.validateRequired(v, 'Roll number or Handle'),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Password',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/forgot-password'),
                child: Row(
                  children: const [
                    Icon(Icons.help_outline_rounded, size: 14, color: AppColors.accentBlue),
                    SizedBox(width: 4),
                    Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          AppTextField(
            hintText: 'Enter your password',
            controller: _loginPasswordController,
            isPassword: true,
            validator: InputValidators.validatePassword,
          ),
          const SizedBox(height: 24),
          AppButton(
            text: 'Log In',
            isLoading: _isLoading,
            onPressed: _handleLogin,
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpForm() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Form(
      key: _signUpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Full Name & Roll No
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Full Name',
                  hintText: 'e.g. Abhishek',
                  controller: _nameController,
                  isRequired: true,
                  validator: InputValidators.validateFullName,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  label: 'Roll No (ID)',
                  hintText: '24BCS101',
                  controller: _rollController,
                  isRequired: true,
                  validator: InputValidators.validateRollNumber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Row 2: Handle & Branch
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Handle',
                  hintText: '@Abhishek07',
                  controller: _handleController,
                  isRequired: true,
                  validator: InputValidators.validateHandle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: 'Branch',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                        children: const [
                          TextSpan(text: ' *', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedBranch,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: AppConstants.branches.map((b) {
                        return DropdownMenuItem(
                          value: b,
                          child: Text(
                            b,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedBranch = val);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Row 3: Hostel & WhatsApp (Optional)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: 'Hostel',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                        children: const [
                          TextSpan(text: ' *', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedHostel,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: AppConstants.hostels.map((h) {
                        return DropdownMenuItem(
                          value: h,
                          child: Text(
                            h,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedHostel = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  label: 'WhatsApp (Optional)',
                  hintText: '+91...',
                  controller: _whatsappController,
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Row 4: Create Password & Re-enter Password
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Create Password',
                  hintText: '••••••••',
                  controller: _signUpPasswordController,
                  isPassword: true,
                  isRequired: true,
                  validator: InputValidators.validatePassword,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  label: 'Re-enter Password',
                  hintText: '••••••••',
                  controller: _confirmPasswordController,
                  isPassword: true,
                  isRequired: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Confirm password';
                    if (v != _signUpPasswordController.text) return 'Does not match';
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Security Question Card (Highlighted blue box from screenshot)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF132035) : AppColors.securityCardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? const Color(0xFF1E3A8A) : AppColors.securityCardBorder,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.vpn_key_rounded, size: 16, color: AppColors.accentBlue),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Security Question (For Password Recovery) *',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedSecurityQuestion,
                  isExpanded: true,
                  decoration: InputDecoration(
                    fillColor: isDark ? AppColors.surfaceDark : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: AppConstants.securityQuestions.map((q) {
                    return DropdownMenuItem(
                      value: q,
                      child: Text(
                        q,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12.5),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedSecurityQuestion = val);
                  },
                ),
                const SizedBox(height: 10),
                AppTextField(
                  hintText: 'Your secret answer *',
                  controller: _securityAnswerController,
                  validator: InputValidators.validateSecurityAnswer,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Row 5: Instagram ID & LinkedIn ID (Optional)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Instagram ID (Opt)',
                  hintText: 'username',
                  controller: _instagramController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  label: 'LinkedIn ID (Opt)',
                  hintText: 'profile-id',
                  controller: _linkedinController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Promotional Consent Checkbox (matching screenshot)
          CheckboxListTile(
            value: _allowPromotionalConsent,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: AppColors.primary,
            dense: true,
            title: Text(
              'Allow featuring my verified campus achievements in highlights',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            onChanged: (val) {
              setState(() {
                _allowPromotionalConsent = val ?? false;
              });
            },
          ),
          const SizedBox(height: 16),

          // Create safe account button
          AppButton(
            text: 'Create safe account',
            isLoading: _isLoading,
            onPressed: _handleSignUp,
          ),
        ],
      ),
    );
  }
}
