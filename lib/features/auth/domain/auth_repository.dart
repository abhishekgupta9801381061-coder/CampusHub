import 'user.dart';

abstract class AuthRepository {
  Future<User?> getCurrentUser();

  Future<User> register({
    required String name,
    required String handle,
    required String rollNo,
    required String branch,
    required String hostel,
    required String password,
    required String securityQuestion,
    required String securityAnswer,
    String? whatsappOptional,
    String? instagramOptional,
    String? linkedinOptional,
    bool allowPromotionalConsent = false,
  });

  Future<User> login({
    required String rollNoOrHandle,
    required String password,
  });

  Future<String?> getSecurityQuestion(String rollNoOrHandle);

  Future<bool> verifySecurityAnswer({
    required String rollNoOrHandle,
    required String answer,
  });

  Future<void> resetPassword({
    required String rollNoOrHandle,
    required String answer,
    required String newPassword,
  });

  Future<void> updateUser(User user);

  Future<void> toggleGhostMode(bool enabled);

  Future<void> updatePromotionalConsent(bool consent);

  Future<void> logout();
}
