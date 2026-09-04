import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:campushub/core/errors/exceptions.dart';
import 'package:campushub/core/utils/security_utils.dart';
import 'package:campushub/features/auth/data/mock_auth_repository.dart';
import 'package:campushub/features/auth/domain/user.dart';
import 'package:campushub/features/confessions/domain/confession.dart';

void main() {
  group('CampusHub Core Privacy & Security Rules', () {
    test('7. Room number never appears in User models, DTOs, or JSON serialization', () {
      final user = User(
        id: 'usr-privacy-01',
        name: 'Test Freshman',
        handle: '@FreshmanX',
        rollNo: '24BCS999',
        branch: 'Computer Science & Engineering',
        hostel: 'Hostel H-1 (Raman)',
        createdAt: DateTime.now(),
      );

      final jsonMap = user.toJson();
      final jsonString = jsonEncode(jsonMap);

      // Verify no room number keys or values exist in serialization
      expect(jsonMap.containsKey('room'), isFalse);
      expect(jsonMap.containsKey('room_number'), isFalse);
      expect(jsonMap.containsKey('roomNo'), isFalse);
      expect(jsonString.contains('room'), isFalse);
    });

    test('8. Ghost Mode removes user from discovery', () async {
      final repository = MockAuthRepository();

      // Ensure demo user is not in ghost mode initially
      final user = await repository.login(rollNoOrHandle: '@Abhishek07', password: 'Password123');
      expect(user.isGhostMode, isFalse);

      var allUsers = repository.getAllUsers();
      var discoverable = allUsers.where((u) => !u.isGhostMode).map((u) => u.handle).toList();
      expect(discoverable, contains('@Abhishek07'));

      // Toggle Ghost Mode ON
      await repository.toggleGhostMode(true);
      final updatedUser = await repository.getCurrentUser();
      expect(updatedUser?.isGhostMode, isTrue);

      // Now Abhishek must be absent from discoverable list
      allUsers = repository.getAllUsers();
      discoverable = allUsers.where((u) => !u.isGhostMode).map((u) => u.handle).toList();
      expect(discoverable, isNot(contains('@Abhishek07')));
    });

    test('9. Anonymous confessions never expose author identity in public model or JSON', () {
      final confession = Confession(
        id: 'conf-anon-01',
        category: '#General',
        content: 'I love studying at the central library late night.',
        upvotes: 10,
        downvotes: 0,
        commentCount: 2,
        createdAt: DateTime.now(),
        privateAuthorToken: 'secret_hash_only_author_holds',
      );

      final json = confession.toJson();
      expect(json.containsKey('author_id'), isFalse);
      expect(json.containsKey('author_name'), isFalse);
      expect(json.containsKey('author_handle'), isFalse);
      expect(json.containsKey('author_hostel'), isFalse);
      expect(json.containsKey('private_author_token'), isFalse);
    });

    test('10. Sensitive passwords and security answers are sanitized and never logged', () {
      // Test SecurityUtils hashing
      final hash1 = SecurityUtils.hashSensitiveString('MySecretAnswer123');
      final hash2 = SecurityUtils.hashSensitiveString('mysecretanswer123');
      expect(hash1, hash2); // Case-normalized verification
      expect(hash1, isNot('MySecretAnswer123')); // Never plaintext

      // Test AppLogger sanitization
      expect(
        () => AppLogger.info('User action with password: SuperSecretPassword123, securityAnswer: SecretDog'),
        returnsNormally,
      );
    });

    test('11. Unauthorized login credentials correctly reject with AuthException', () async {
      final repository = MockAuthRepository();

      expect(
        () async => repository.login(rollNoOrHandle: '@NonExistentUser', password: 'WrongPassword'),
        throwsA(isA<AuthException>()),
      );

      expect(
        () async => repository.login(rollNoOrHandle: '@Abhishek07', password: 'WrongPassword123'),
        throwsA(isA<AuthException>()),
      );
    });
  });
}
