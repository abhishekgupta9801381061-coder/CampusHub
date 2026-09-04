import 'package:uuid/uuid.dart';
import '../domain/confession.dart';
import '../domain/confession_repository.dart';

class MockConfessionRepository implements ConfessionRepository {
  final List<Confession> _confessions = [];
  final List<ConfessionComment> _comments = [];

  MockConfessionRepository() {
    _seedData();
  }

  void _seedData() {
    final now = DateTime.now();
    _confessions.addAll([
      Confession(
        id: 'conf-01',
        category: '#General',
        content: 'Is it normal to feel completely overwhelmed during the first month of college? Everyone acts like they know DSA and web dev already.',
        upvotes: 42,
        downvotes: 1,
        commentCount: 9,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      Confession(
        id: 'conf-02',
        category: '#Hostel',
        content: 'The mess food in Raman hostel today was surprisingly good. Paneer butter masala that actually tasted like restaurant food.',
        upvotes: 28,
        downvotes: 3,
        commentCount: 4,
        createdAt: now.subtract(const Duration(hours: 8)),
      ),
      Confession(
        id: 'conf-03',
        category: '#CSE',
        content: 'Pro tip for 1st sem: do not skip C programming pointers lectures. Mid terms will punish you hard.',
        upvotes: 65,
        downvotes: 0,
        commentCount: 12,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ]);

    _comments.addAll([
      ConfessionComment(
        id: 'c-01',
        confessionId: 'conf-01',
        content: '100% normal! Imposter syndrome is huge in 1st year. You got this, pace yourself.',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      ConfessionComment(
        id: 'c-02',
        confessionId: 'conf-01',
        content: 'Same here. Don’t compare your chapter 1 with someone else’s chapter 10.',
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
    ]);
  }

  @override
  Future<List<Confession>> getConfessions({String? category}) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _confessions.where((c) {
      if (category != null && category.isNotEmpty && category != '#All' && c.category != category) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Confession> postConfession({
    required String category,
    required String content,
    required String authorSecret,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newConfession = Confession(
      id: const Uuid().v4(),
      category: category,
      content: content.trim(),
      upvotes: 1,
      hasUpvoted: true,
      createdAt: DateTime.now(),
      privateAuthorToken: authorSecret,
    );
    _confessions.insert(0, newConfession);
    return newConfession;
  }

  @override
  Future<void> upvoteConfession(String id) async {
    final index = _confessions.indexWhere((c) => c.id == id);
    if (index != -1) {
      final c = _confessions[index];
      if (c.hasUpvoted) {
        _confessions[index] = c.copyWith(upvotes: c.upvotes - 1, hasUpvoted: false);
      } else {
        _confessions[index] = c.copyWith(
          upvotes: c.upvotes + 1,
          hasUpvoted: true,
          downvotes: c.hasDownvoted ? c.downvotes - 1 : c.downvotes,
          hasDownvoted: false,
        );
      }
    }
  }

  @override
  Future<void> downvoteConfession(String id) async {
    final index = _confessions.indexWhere((c) => c.id == id);
    if (index != -1) {
      final c = _confessions[index];
      if (c.hasDownvoted) {
        _confessions[index] = c.copyWith(downvotes: c.downvotes - 1, hasDownvoted: false);
      } else {
        _confessions[index] = c.copyWith(
          downvotes: c.downvotes + 1,
          hasDownvoted: true,
          upvotes: c.hasUpvoted ? c.upvotes - 1 : c.upvotes,
          hasUpvoted: false,
        );
      }
    }
  }

  @override
  Future<List<ConfessionComment>> getComments(String confessionId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _comments.where((cm) => cm.confessionId == confessionId).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Future<void> addComment({required String confessionId, required String content}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _comments.add(
      ConfessionComment(
        id: const Uuid().v4(),
        confessionId: confessionId,
        content: content.trim(),
        createdAt: DateTime.now(),
      ),
    );

    final index = _confessions.indexWhere((c) => c.id == confessionId);
    if (index != -1) {
      final c = _confessions[index];
      _confessions[index] = c.copyWith(commentCount: c.commentCount + 1);
    }
  }

  @override
  Future<void> deleteConfession({required String id, required String authorSecret}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _confessions.removeWhere((c) => c.id == id && c.privateAuthorToken == authorSecret);
  }

  @override
  Future<void> reportConfession(String id) async {
    // Moderation queue hook
  }
}
