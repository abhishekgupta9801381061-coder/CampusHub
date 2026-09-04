import 'package:flutter_test/flutter_test.dart';
import 'package:campushub/core/constants/app_constants.dart';
import 'package:campushub/core/errors/exceptions.dart';
import 'package:campushub/features/partner_requests/data/mock_partner_request_repository.dart';
import 'package:campushub/features/partner_requests/domain/partner_request.dart';

void main() {
  group('Partner Request Business Rules & Rate Limits', () {
    late MockPartnerRequestRepository repository;

    setUp(() {
      repository = MockPartnerRequestRepository();
    });

    test('1. User cannot create 2 partner requests on the same calendar day', () async {
      const testUserId = 'test-freshman-user-99';

      // First creation on this calendar day should succeed
      final firstRequest = await repository.createRequest(
        authorId: testUserId,
        authorName: 'Rohan Sharma',
        authorHandle: '@Rohan_99',
        authorBranch: 'Computer Science & Engineering',
        authorHostel: 'Hostel H-1 (Raman)',
        type: 'Hackathon Team',
        title: 'Need a Flutter dev for Hackathon',
        description: 'Building an innovative campus project together.',
        tags: ['Flutter', 'Hackathon'],
      );

      expect(firstRequest.id, isNotEmpty);
      expect(firstRequest.authorId, testUserId);

      // Second creation on the same calendar day must throw RateLimitException
      expect(
        () async => repository.createRequest(
          authorId: testUserId,
          authorName: 'Rohan Sharma',
          authorHandle: '@Rohan_99',
          authorBranch: 'Computer Science & Engineering',
          authorHostel: 'Hostel H-1 (Raman)',
          type: 'Startup Co-Founder',
          title: 'Second request on the same day',
          description: 'This must be blocked by rate limit.',
          tags: ['Startup'],
        ),
        throwsA(isA<RateLimitException>()),
      );
    });

    test('2. User can create a new request the next calendar day', () async {
      const testUserId = 'test-freshman-user-yesterday';

      // Create a request timestamped yesterday
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final pastRequest = PartnerRequest(
        id: 'past-req-01',
        authorId: testUserId,
        authorName: 'Vikram',
        authorHandle: '@Vikram',
        authorBranch: 'Mechanical Engineering',
        authorHostel: 'Hostel H-2 (Aryabhata)',
        type: 'Course Project',
        title: 'CAD Project Partner needed',
        description: 'Looking for a teammate for design simulation.',
        createdAt: yesterday,
      );

      expect(repository.canUserCreateToday(testUserId), completion(isTrue));

      // Creation today succeeds
      final todayRequest = await repository.createRequest(
        authorId: testUserId,
        authorName: 'Vikram',
        authorHandle: '@Vikram',
        authorBranch: 'Mechanical Engineering',
        authorHostel: 'Hostel H-2 (Aryabhata)',
        type: 'Study Partner',
        title: 'Midterm prep group',
        description: 'Solving mechanics problems in library.',
        tags: ['Mechanics'],
      );

      expect(todayRequest.id, isNotEmpty);
    });

    test('3. User cannot edit a request more than 3 times in one calendar day', () async {
      const testUserId = 'test-freshman-editor';

      final req = await repository.createRequest(
        authorId: testUserId,
        authorName: 'Ananya',
        authorHandle: '@Ananya',
        authorBranch: 'Data Science & AI',
        authorHostel: 'Hostel G-1 (Kalpana)',
        type: 'Research Paper',
        title: 'Research Paper in NLP',
        description: 'Investigating transformer architectures.',
        tags: ['NLP', 'AI'],
      );

      // Edit 1: Allowed
      final e1 = await repository.updateRequest(
        requestId: req.id,
        userId: testUserId,
        title: 'NLP Research - Edit 1',
        description: 'Updated scope description.',
        tags: ['NLP'],
      );
      expect(e1.editCount, 1);

      // Edit 2: Allowed
      final e2 = await repository.updateRequest(
        requestId: req.id,
        userId: testUserId,
        title: 'NLP Research - Edit 2',
        description: 'Updated scope description again.',
        tags: ['NLP'],
      );
      expect(e2.editCount, 2);

      // Edit 3: Allowed (reaches maximum daily quota of 3)
      final e3 = await repository.updateRequest(
        requestId: req.id,
        userId: testUserId,
        title: 'NLP Research - Edit 3',
        description: 'Final daily edit.',
        tags: ['NLP'],
      );
      expect(e3.editCount, 3);

      // Edit 4 on the same calendar day: Must throw RateLimitException
      expect(
        () async => repository.updateRequest(
          requestId: req.id,
          userId: testUserId,
          title: 'NLP Research - Edit 4 (Violating)',
          description: 'This 4th edit must be blocked.',
          tags: ['NLP'],
        ),
        throwsA(isA<RateLimitException>()),
      );
    });

    test('4. Request expires after 5 days', () {
      final now = DateTime.now();

      final recentRequest = PartnerRequest(
        id: 'r-fresh',
        authorId: 'u1',
        authorName: 'Rohan',
        authorHandle: '@Rohan',
        authorBranch: 'CSE',
        authorHostel: 'Hostel H-1 (Raman)',
        type: 'Hackathon Team',
        title: 'Hackathon Team',
        description: 'Testing description',
        createdAt: now.subtract(const Duration(days: 4, hours: 23)),
      );
      expect(recentRequest.isExpired, isFalse);

      final expiredRequest = PartnerRequest(
        id: 'r-old',
        authorId: 'u1',
        authorName: 'Rohan',
        authorHandle: '@Rohan',
        authorBranch: 'CSE',
        authorHostel: 'Hostel H-1 (Raman)',
        type: 'Hackathon Team',
        title: 'Hackathon Team',
        description: 'Testing description',
        createdAt: now.subtract(const Duration(days: 5, hours: 1)),
      );
      expect(expiredRequest.isExpired, isTrue);
    });

    test('5. User can delete a request at any time', () async {
      const testUserId = 'delete-user';

      final req = await repository.createRequest(
        authorId: testUserId,
        authorName: 'User',
        authorHandle: '@User',
        authorBranch: 'CSE',
        authorHostel: 'Hostel H-1 (Raman)',
        type: 'Hackathon Team',
        title: 'To be deleted',
        description: 'Temporary description',
        tags: [],
      );

      // Verify request is active
      final activeBefore = await repository.getActiveRequests();
      expect(activeBefore.any((r) => r.id == req.id), isTrue);

      // User deletes request
      await repository.deleteRequest(requestId: req.id, userId: testUserId);

      // Verify request is removed
      final activeAfter = await repository.getActiveRequests();
      expect(activeAfter.any((r) => r.id == req.id), isFalse);
    });
  });
}
