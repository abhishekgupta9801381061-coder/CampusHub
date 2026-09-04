import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/errors/exceptions.dart';
import '../domain/partner_request.dart';
import '../domain/partner_request_repository.dart';

class MockPartnerRequestRepository implements PartnerRequestRepository {
  final List<PartnerRequest> _requests = [];

  MockPartnerRequestRepository() {
    _seedData();
  }

  void _seedData() {
    final now = DateTime.now();
    _requests.addAll([
      PartnerRequest(
        id: 'req-001',
        authorId: 'usr-freshman-02',
        authorName: 'Priya Sharma',
        authorHandle: '@PriyaCS',
        authorBranch: 'Computer Science & Engineering',
        authorHostel: 'Hostel G-1 (Kalpana)',
        type: 'Hackathon Team',
        title: 'Looking for ML/Flutter dev for Smart India Hackathon',
        description: 'We are building a smart campus navigation & waste reduction app. Looking for a teammate passionate about Flutter or TensorFlow Lite.',
        tags: const ['Flutter', 'Machine Learning', 'SIH2026'],
        createdAt: now.subtract(const Duration(days: 1, hours: 4)),
      ),
      PartnerRequest(
        id: 'req-002',
        authorId: 'usr-freshman-03',
        authorName: 'Arjun Verma',
        authorHandle: '@Arjun_Mech',
        authorBranch: 'Mechanical Engineering',
        authorHostel: 'Hostel H-2 (Aryabhata)',
        type: 'Startup Co-Founder',
        title: 'Hardware Co-Founder for EV Drone Delivery',
        description: 'Working on low-cost telemetry and battery pack optimization. Seeking a freshman co-founder to build prototypes together.',
        tags: const ['Drones', 'SolidWorks', 'Startup'],
        createdAt: now.subtract(const Duration(days: 2, hours: 8)),
      ),
      PartnerRequest(
        id: 'req-003',
        authorId: 'usr-freshman-04',
        authorName: 'Sneha Rao',
        authorHandle: '@Sneha_Robo',
        authorBranch: 'Electronics & Communication',
        authorHostel: 'Hostel G-2 (Gargi)',
        type: 'Study Partner',
        title: 'Engineering Mathematics & Circuit Theory Study Group',
        description: 'Prepping for mid-semesters. Let us solve previous year questions daily in library 6 PM to 8 PM.',
        tags: const ['Maths', 'Circuits', 'Academics'],
        createdAt: now.subtract(const Duration(hours: 14)),
      ),
    ]);
  }

  bool _isSameCalendarDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Future<bool> canUserCreateToday(String userId) async {
    final today = DateTime.now();
    final hasCreatedToday = _requests.any(
      (r) => r.authorId == userId && _isSameCalendarDay(r.createdAt, today),
    );
    return !hasCreatedToday;
  }

  @override
  Future<List<PartnerRequest>> getActiveRequests({String? typeFilter, String? query}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _requests.where((r) {
      if (r.isExpired || r.isClosed) return false;
      if (typeFilter != null && typeFilter.isNotEmpty && r.type != typeFilter) return false;
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        final matchTitle = r.title.toLowerCase().contains(q);
        final matchDesc = r.description.toLowerCase().contains(q);
        final matchTags = r.tags.any((t) => t.toLowerCase().contains(q));
        if (!matchTitle && !matchDesc && !matchTags) return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<PartnerRequest>> getMyRequests(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _requests.where((r) => r.authorId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<PartnerRequest> getRequestById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final req = _requests.firstWhere(
      (r) => r.id == id,
      orElse: () => throw const ServerException('Partner request not found', 404),
    );
    return req;
  }

  @override
  Future<PartnerRequest> createRequest({
    required String authorId,
    required String authorName,
    required String authorHandle,
    required String authorBranch,
    required String authorHostel,
    required String type,
    required String title,
    required String description,
    required List<String> tags,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // Enforce 1 per calendar day rule
    final canCreate = await canUserCreateToday(authorId);
    if (!canCreate) {
      throw const RateLimitException(AppStrings.partnerRequestDailyLimitReached);
    }

    final newRequest = PartnerRequest(
      id: const Uuid().v4(),
      authorId: authorId,
      authorName: authorName,
      authorHandle: authorHandle,
      authorBranch: authorBranch,
      authorHostel: authorHostel,
      type: type,
      title: title.trim(),
      description: description.trim(),
      tags: tags,
      createdAt: DateTime.now(),
      editCount: 0,
    );

    _requests.insert(0, newRequest);
    return newRequest;
  }

  @override
  Future<PartnerRequest> updateRequest({
    required String requestId,
    required String userId,
    required String title,
    required String description,
    required List<String> tags,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) {
      throw const ServerException('Partner request not found', 404);
    }

    final existing = _requests[index];
    if (existing.authorId != userId) {
      throw const ServerException('You can only edit your own partner requests', 403);
    }

    final now = DateTime.now();
    // Check if edited today
    int newEditCount = existing.editCount;
    if (existing.lastEditedAt != null && _isSameCalendarDay(existing.lastEditedAt!, now)) {
      if (existing.editCount >= AppConstants.maxPartnerRequestEditsPerDay) {
        throw const RateLimitException(AppStrings.partnerRequestEditLimitReached);
      }
      newEditCount += 1;
    } else {
      // Reset edit count for a new calendar day
      newEditCount = 1;
    }

    final updated = existing.copyWith(
      title: title.trim(),
      description: description.trim(),
      tags: tags,
      editCount: newEditCount,
      lastEditedAt: now,
    );

    _requests[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteRequest({required String requestId, required String userId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      if (_requests[index].authorId != userId) {
        throw const ServerException('Unauthorized to delete this request', 403);
      }
      _requests.removeAt(index);
    }
  }

  @override
  Future<void> reportRequest(String requestId) async {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      final existing = _requests[index];
      _requests[index] = existing.copyWith(reportCount: existing.reportCount + 1);
    }
  }
}
