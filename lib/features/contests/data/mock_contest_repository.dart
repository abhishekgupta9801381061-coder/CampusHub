import '../../../core/errors/exceptions.dart';
import '../domain/contest.dart';
import '../domain/contest_repository.dart';

class MockContestRepository implements ContestRepository {
  final List<Contest> _contests = [];

  MockContestRepository() {
    _seedData();
  }

  void _seedData() {
    final now = DateTime.now();
    _contests.addAll([
      Contest(
        id: 'c-01',
        title: 'Smart India Hackathon (SIH 2026)',
        organizer: 'Ministry of Education & AICTE',
        eventDate: now.add(const Duration(days: 28)),
        deadline: now.add(const Duration(days: 10)),
        mode: 'Hybrid',
        tags: const ['National', 'Hardware', 'Software', 'AI'],
        description: 'Nationwide initiative to provide students with a platform to solve some of the pressing problems we face in our daily lives, and thus inculcate a culture of product innovation.',
        prizePool: '₹1,00,000 per problem statement',
        registrationUrl: 'https://sih.gov.in',
        isBookmarked: true,
      ),
      Contest(
        id: 'c-02',
        title: 'Campus Genesis Freshman Hackathon',
        organizer: 'CampusHub Student Chapter & EDC',
        eventDate: now.add(const Duration(days: 14)),
        deadline: now.add(const Duration(days: 6)),
        mode: 'On-Campus',
        tags: const ['Freshmen Only', 'Web Dev', 'Mobile', 'UI/UX'],
        description: 'A 24-hour beginner-friendly hackathon specifically designed for 1st-year university students. Mentorship and food provided.',
        prizePool: '₹50,000 + Swags & Incubation',
        registrationUrl: 'https://campushub.internal/genesis',
        isBookmarked: false,
      ),
      Contest(
        id: 'c-03',
        title: 'Google Solution Challenge 2026',
        organizer: 'Google Developer Student Clubs',
        eventDate: now.add(const Duration(days: 45)),
        deadline: now.add(const Duration(days: 20)),
        mode: 'Online',
        tags: const ['Global', 'UN Goals', 'Flutter', 'Cloud'],
        description: 'Build a solution to a local or global problem using Google technologies in support of the United Nations 17 Sustainable Development Goals.',
        prizePool: '\$10,000 top prize + Mentorship',
        registrationUrl: 'https://developers.google.com/community/gdsc-solution-challenge',
        isBookmarked: false,
      ),
    ]);
  }

  @override
  Future<List<Contest>> getContests({String? query, bool? bookmarkedOnly}) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _contests.where((c) {
      if (bookmarkedOnly == true && !c.isBookmarked) return false;
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        final matchTitle = c.title.toLowerCase().contains(q);
        final matchOrg = c.organizer.toLowerCase().contains(q);
        final matchTag = c.tags.any((t) => t.toLowerCase().contains(q));
        if (!matchTitle && !matchOrg && !matchTag) return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<Contest> getContestById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _contests.firstWhere(
      (c) => c.id == id,
      orElse: () => throw const ServerException('Contest not found', 404),
    );
  }

  @override
  Future<void> toggleBookmark(String contestId) async {
    final index = _contests.indexWhere((c) => c.id == contestId);
    if (index != -1) {
      final existing = _contests[index];
      _contests[index] = existing.copyWith(isBookmarked: !existing.isBookmarked);
    }
  }
}
