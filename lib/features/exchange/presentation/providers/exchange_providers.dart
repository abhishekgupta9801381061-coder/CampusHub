import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_exchange_repository.dart';
import '../../domain/exchange_listing.dart';
import '../../domain/exchange_repository.dart';

final exchangeRepositoryProvider = Provider<ExchangeRepository>((ref) {
  return MockExchangeRepository();
});

final exchangeCategoryFilterProvider = StateProvider<String>((ref) => 'All');
final exchangeSearchQueryProvider = StateProvider<String>((ref) => '');

final exchangeListingsProvider = FutureProvider<List<ExchangeListing>>((ref) async {
  final repo = ref.watch(exchangeRepositoryProvider);
  final category = ref.watch(exchangeCategoryFilterProvider);
  final query = ref.watch(exchangeSearchQueryProvider);
  return repo.getListings(category: category == 'All' ? null : category, query: query);
});
