import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_local_storage.dart';
import '../../data/mock_auth_repository.dart';
import '../../domain/auth_repository.dart';
import '../../domain/user.dart';

final authLocalStorageProvider = Provider<AuthLocalStorage>((ref) {
  return AuthLocalStorage();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final storage = ref.watch(authLocalStorageProvider);
  return MockAuthRepository(localStorage: storage);
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.loading()) {
    checkCurrentUser();
  }

  Future<void> checkCurrentUser() async {
    try {
      final user = await _repository.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> login(String rollNoOrHandle, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.login(
        rollNoOrHandle: rollNoOrHandle,
        password: password,
      );
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> register({
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
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.register(
        name: name,
        handle: handle,
        rollNo: rollNo,
        branch: branch,
        hostel: hostel,
        password: password,
        securityQuestion: securityQuestion,
        securityAnswer: securityAnswer,
        whatsappOptional: whatsappOptional,
        instagramOptional: instagramOptional,
        linkedinOptional: linkedinOptional,
        allowPromotionalConsent: allowPromotionalConsent,
      );
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> toggleGhostMode(bool enabled) async {
    final current = state.value;
    if (current == null) return;
    final updated = current.copyWith(isGhostMode: enabled);
    state = AsyncValue.data(updated);
    await _repository.toggleGhostMode(enabled);
  }

  Future<void> updatePromotionalConsent(bool consent) async {
    final current = state.value;
    if (current == null) return;
    final updated = current.copyWith(allowPromotionalConsent: consent);
    state = AsyncValue.data(updated);
    await _repository.updatePromotionalConsent(consent);
  }

  Future<void> updateUser(User user) async {
    state = AsyncValue.data(user);
    await _repository.updateUser(user);
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncValue.data(null);
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authNotifierProvider).value;
});

final isGhostModeProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider)?.isGhostMode ?? false;
});
