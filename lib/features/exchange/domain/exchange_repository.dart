import 'exchange_listing.dart';

abstract class ExchangeRepository {
  Future<List<ExchangeListing>> getListings({String? category, String? query});
  Future<ExchangeListing> createListing({
    required String itemName,
    required String description,
    required String condition,
    required String category,
    required String ownerId,
    required String ownerHandle,
    required String hostel,
    required String priceOrFree,
  });
  Future<void> markAsClaimed(String id);
}
