import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_partner_request_repository.dart';
import '../../domain/partner_request.dart';
import '../../domain/partner_request_repository.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

final partnerRequestRepositoryProvider = Provider<PartnerRequestRepository>((ref) {
  return MockPartnerRequestRepository();
});

final selectedRequestTypeFilterProvider = StateProvider<String?>((ref) => null);
final searchQueryPartnerProvider = StateProvider<String>((ref) => '');

final activePartnerRequestsProvider = FutureProvider<List<PartnerRequest>>((ref) async {
  final repo = ref.watch(partnerRequestRepositoryProvider);
  final typeFilter = ref.watch(selectedRequestTypeFilterProvider);
  final query = ref.watch(searchQueryPartnerProvider);
  return repo.getActiveRequests(typeFilter: typeFilter, query: query);
});

final myPartnerRequestsProvider = FutureProvider<List<PartnerRequest>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final repo = ref.watch(partnerRequestRepositoryProvider);
  return repo.getMyRequests(user.id);
});

final canCreatePartnerRequestTodayProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  final repo = ref.watch(partnerRequestRepositoryProvider);
  return repo.canUserCreateToday(user.id);
});
