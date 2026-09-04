import 'package:flutter_test/flutter_test.dart';
import 'package:campushub/core/errors/exceptions.dart';
import 'package:campushub/features/groups/data/mock_group_repository.dart';

void main() {
  group('Groups Business Rules', () {
    late MockGroupRepository repository;

    setUp(() {
      repository = MockGroupRepository();
    });

    test('6. User cannot create more than 4 active groups', () async {
      const testUserId = 'test-creator-group-limit';

      // Create Group 1
      await repository.createGroup(
        name: 'Group 1',
        description: 'First group description',
        category: 'Hackathon Team',
        tags: ['G1'],
        creatorId: testUserId,
        creatorHandle: '@Leader',
        creatorName: 'Group Leader',
        creatorBranch: 'CSE',
        creatorHostel: 'Hostel H-1 (Raman)',
      );

      // Create Group 2
      await repository.createGroup(
        name: 'Group 2',
        description: 'Second group description',
        category: 'Robotics',
        tags: ['G2'],
        creatorId: testUserId,
        creatorHandle: '@Leader',
        creatorName: 'Group Leader',
        creatorBranch: 'CSE',
        creatorHostel: 'Hostel H-1 (Raman)',
      );

      // Create Group 3
      await repository.createGroup(
        name: 'Group 3',
        description: 'Third group description',
        category: 'AI & Machine Learning',
        tags: ['G3'],
        creatorId: testUserId,
        creatorHandle: '@Leader',
        creatorName: 'Group Leader',
        creatorBranch: 'CSE',
        creatorHostel: 'Hostel H-1 (Raman)',
      );

      // Create Group 4
      await repository.createGroup(
        name: 'Group 4',
        description: 'Fourth group description',
        category: 'Startup Team',
        tags: ['G4'],
        creatorId: testUserId,
        creatorHandle: '@Leader',
        creatorName: 'Group Leader',
        creatorBranch: 'CSE',
        creatorHostel: 'Hostel H-1 (Raman)',
      );

      final count = await repository.getUserCreatedGroupCount(testUserId);
      expect(count, 4);

      // Attempting to create a 5th active group must be rejected with RateLimitException
      expect(
        () async => repository.createGroup(
          name: 'Group 5 (Violating Limit)',
          description: 'This 5th group must be blocked.',
          category: 'Course Study Group',
          tags: ['G5'],
          creatorId: testUserId,
          creatorHandle: '@Leader',
          creatorName: 'Group Leader',
          creatorBranch: 'CSE',
          creatorHostel: 'Hostel H-1 (Raman)',
        ),
        throwsA(isA<RateLimitException>()),
      );
    });
  });
}
