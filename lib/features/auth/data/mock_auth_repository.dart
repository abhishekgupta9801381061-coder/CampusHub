import 'package:uuid/uuid.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/utils/security_utils.dart';
import '../domain/auth_repository.dart';
import '../domain/user.dart';
import 'auth_local_storage.dart';

class _UserAuthRecord {
  final User user;
  String passwordHash;
  final String securityQuestion;
  String securityAnswerHash;

  _UserAuthRecord({
    required this.user,
    required this.passwordHash,
    required this.securityQuestion,
    required this.securityAnswerHash,
  });
}

class MockAuthRepository implements AuthRepository {
  final AuthLocalStorage _localStorage;
  final Map<String, _UserAuthRecord> _usersById = {};
  User? _currentUser;

  MockAuthRepository({AuthLocalStorage? localStorage})
      : _localStorage = localStorage ?? AuthLocalStorage() {
    _seedDefaultUsers();
  }

  void _seedDefaultUsers() {
    // Demo Freshman user matching the user screenshot
    final demoUser = User(
      id: 'usr-freshman-01',
      name: 'Abhishek Kumar',
      handle: '@Abhishek07',
      rollNo: '24BCS10142',
      branch: 'Computer Science & Engineering',
      hostel: 'Hostel H-1 (Raman)',
      isGhostMode: false,
      allowPromotionalConsent: true,
      skills: const ['Flutter', 'Python', 'Dart', 'FastAPI'],
      interests: const ['AI/ML', 'Hackathons', 'Open Source'],
      whatsappOptional: '+91 9876543210',
      instagramOptional: 'abhishek_builds',
      linkedinOptional: 'abhishek-freshman',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );

    _usersById[demoUser.id] = _UserAuthRecord(
      user: demoUser,
      passwordHash: SecurityUtils.hashSensitiveString('Password123'),
      securityQuestion: 'What is your favorite programming language or tech skill?',
      securityAnswerHash: SecurityUtils.hashSensitiveString('Flutter'),
    );

    // Other classmates
    final classmates = [
      User(
        id: 'usr-freshman-02',
        name: 'Priya Sharma',
        handle: '@PriyaCS',
        rollNo: '24BCS10088',
        branch: 'Computer Science & Engineering',
        hostel: 'Hostel G-1 (Kalpana)',
        skills: const ['React', 'Figma', 'UI/UX'],
        interests: const ['Design Systems', 'Web3'],
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      User(
        id: 'usr-freshman-03',
        name: 'Arjun Verma',
        handle: '@Arjun_Mech',
        rollNo: '24BME10012',
        branch: 'Mechanical Engineering',
        hostel: 'Hostel H-2 (Aryabhata)',
        skills: const ['SolidWorks', 'MATLAB', 'Robotics'],
        interests: const ['Drones', 'Formula Student'],
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      User(
        id: 'usr-freshman-04',
        name: 'Sneha Rao',
        handle: '@Sneha_Robo',
        rollNo: '24ECE10045',
        branch: 'Electronics & Communication',
        hostel: 'Hostel G-2 (Gargi)',
        skills: const ['Arduino', 'C++', 'IoT', 'Embedded Systems'],
        interests: const ['Robotics', 'Hardware Hacking'],
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];

    for (final cm in classmates) {
      _usersById[cm.id] = _UserAuthRecord(
        user: cm,
        passwordHash: SecurityUtils.hashSensitiveString('Campus123'),
        securityQuestion: 'What was the model of your first phone or laptop?',
        securityAnswerHash: SecurityUtils.hashSensitiveString('Thinkpad'),
      );
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    final cached = await _localStorage.getCachedUser();
    if (cached != null) {
      _currentUser = cached;
      return cached;
    }
    // Auto-login demo user for initial seamless experience if stored token exists
    final token = await _localStorage.getToken();
    if (token != null && _usersById.containsKey(token)) {
      _currentUser = _usersById[token]!.user;
      return _currentUser;
    }
    return null;
  }

  @override
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
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // Handle uniqueness check
    final handleExists = _usersById.values.any(
      (record) => record.user.handle.toLowerCase() == handle.trim().toLowerCase(),
    );
    if (handleExists) {
      throw const AuthException('This handle is already taken. Please choose another.');
    }

    // Roll number uniqueness check
    final rollExists = _usersById.values.any(
      (record) => record.user.rollNo.toUpperCase() == rollNo.trim().toUpperCase(),
    );
    if (rollExists) {
      throw const AuthException('An account with this roll number already exists.');
    }

    final newId = const Uuid().v4();
    final user = User(
      id: newId,
      name: name.trim(),
      handle: handle.trim(),
      rollNo: rollNo.trim().toUpperCase(),
      branch: branch,
      hostel: hostel,
      isGhostMode: false,
      allowPromotionalConsent: allowPromotionalConsent,
      skills: const [],
      interests: const [],
      whatsappOptional: whatsappOptional?.trim(),
      instagramOptional: instagramOptional?.trim(),
      linkedinOptional: linkedinOptional?.trim(),
      createdAt: DateTime.now(),
    );

    _usersById[newId] = _UserAuthRecord(
      user: user,
      passwordHash: SecurityUtils.hashSensitiveString(password),
      securityQuestion: securityQuestion,
      securityAnswerHash: SecurityUtils.hashSensitiveString(securityAnswer),
    );

    _currentUser = user;
    await _localStorage.saveToken(newId);
    await _localStorage.saveCachedUser(user);

    return user;
  }

  @override
  Future<User> login({
    required String rollNoOrHandle,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final identifier = rollNoOrHandle.trim().toLowerCase();
    final enteredPasswordHash = SecurityUtils.hashSensitiveString(password);

    for (final record in _usersById.values) {
      final matchesHandle = record.user.handle.toLowerCase() == identifier;
      final matchesRoll = record.user.rollNo.toLowerCase() == identifier;

      if (matchesHandle || matchesRoll) {
        if (record.passwordHash == enteredPasswordHash) {
          _currentUser = record.user;
          await _localStorage.saveToken(record.user.id);
          await _localStorage.saveCachedUser(record.user);
          return record.user;
        } else {
          throw const AuthException('Invalid password. Please check your credentials.');
        }
      }
    }

    throw const AuthException('No student account found with this Handle or Roll Number.');
  }

  @override
  Future<String?> getSecurityQuestion(String rollNoOrHandle) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final identifier = rollNoOrHandle.trim().toLowerCase();

    for (final record in _usersById.values) {
      if (record.user.handle.toLowerCase() == identifier ||
          record.user.rollNo.toLowerCase() == identifier) {
        return record.securityQuestion;
      }
    }
    return null;
  }

  @override
  Future<bool> verifySecurityAnswer({
    required String rollNoOrHandle,
    required String answer,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final identifier = rollNoOrHandle.trim().toLowerCase();

    for (final record in _usersById.values) {
      if (record.user.handle.toLowerCase() == identifier ||
          record.user.rollNo.toLowerCase() == identifier) {
        return SecurityUtils.verifyHash(answer, record.securityAnswerHash);
      }
    }
    return false;
  }

  @override
  Future<void> resetPassword({
    required String rollNoOrHandle,
    required String answer,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final identifier = rollNoOrHandle.trim().toLowerCase();

    for (final record in _usersById.values) {
      if (record.user.handle.toLowerCase() == identifier ||
          record.user.rollNo.toLowerCase() == identifier) {
        if (SecurityUtils.verifyHash(answer, record.securityAnswerHash)) {
          record.passwordHash = SecurityUtils.hashSensitiveString(newPassword);
          return;
        } else {
          throw const AuthException('Incorrect security answer provided.');
        }
      }
    }
    throw const AuthException('Account not found.');
  }

  @override
  Future<void> updateUser(User user) async {
    if (_usersById.containsKey(user.id)) {
      final existingRecord = _usersById[user.id]!;
      _usersById[user.id] = _UserAuthRecord(
        user: user,
        passwordHash: existingRecord.passwordHash,
        securityQuestion: existingRecord.securityQuestion,
        securityAnswerHash: existingRecord.securityAnswerHash,
      );
      _currentUser = user;
      await _localStorage.saveCachedUser(user);
    }
  }

  @override
  Future<void> toggleGhostMode(bool enabled) async {
    if (_currentUser != null) {
      final updated = _currentUser!.copyWith(isGhostMode: enabled);
      await updateUser(updated);
    }
  }

  @override
  Future<void> updatePromotionalConsent(bool consent) async {
    if (_currentUser != null) {
      final updated = _currentUser!.copyWith(allowPromotionalConsent: consent);
      await updateUser(updated);
    }
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    await _localStorage.clearAll();
  }

  List<User> getAllUsers() {
    return _usersById.values.map((e) => e.user).toList();
  }
}
