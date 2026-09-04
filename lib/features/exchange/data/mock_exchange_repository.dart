import 'package:uuid/uuid.dart';
import '../domain/exchange_listing.dart';
import '../domain/exchange_repository.dart';

class MockExchangeRepository implements ExchangeRepository {
  final List<ExchangeListing> _listings = [];

  MockExchangeRepository() {
    _seedData();
  }

  void _seedData() {
    final now = DateTime.now();
    _listings.addAll([
      ExchangeListing(
        id: 'ex-01',
        itemName: 'Higher Engineering Mathematics (B.S. Grewal)',
        description: 'Hardcover 44th edition. Essential for Sem 1 & Sem 2 engineering mathematics. Clean pages, no torn sheets.',
        condition: 'Gently Used',
        category: 'Textbooks',
        ownerId: 'usr-freshman-02',
        ownerHandle: '@PriyaCS',
        hostel: 'Hostel G-1 (Kalpana)',
        priceOrFree: 'Free / Pay-it-forward',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      ExchangeListing(
        id: 'ex-02',
        itemName: 'Casio fx-991EX ClassWiz Scientific Calculator',
        description: 'Approved for university engineering semester exams. Has matrix operations and equation solvers.',
        condition: 'Like New',
        category: 'Calculators',
        ownerId: 'usr-freshman-03',
        ownerHandle: '@Arjun_Mech',
        hostel: 'Hostel H-2 (Aryabhata)',
        priceOrFree: '₹400',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      ExchangeListing(
        id: 'ex-03',
        itemName: 'Freshman Chemistry & Physics Lab Coat (Size M)',
        description: 'White cotton lab coat required for 1st year chemistry lab. Used only twice, washed and ironed.',
        condition: 'Like New',
        category: 'Lab coats',
        ownerId: 'usr-freshman-04',
        ownerHandle: '@Sneha_Robo',
        hostel: 'Hostel G-2 (Gargi)',
        priceOrFree: '₹120',
        createdAt: now.subtract(const Duration(hours: 18)),
      ),
    ]);
  }

  @override
  Future<List<ExchangeListing>> getListings({String? category, String? query}) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _listings.where((item) {
      if (!item.isAvailable) return false;
      if (category != null && category.isNotEmpty && category != 'All' && item.category != category) {
        return false;
      }
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        final matchName = item.itemName.toLowerCase().contains(q);
        final matchDesc = item.description.toLowerCase().contains(q);
        if (!matchName && !matchDesc) return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<ExchangeListing> createListing({
    required String itemName,
    required String description,
    required String condition,
    required String category,
    required String ownerId,
    required String ownerHandle,
    required String hostel,
    required String priceOrFree,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newListing = ExchangeListing(
      id: const Uuid().v4(),
      itemName: itemName.trim(),
      description: description.trim(),
      condition: condition,
      category: category,
      ownerId: ownerId,
      ownerHandle: ownerHandle,
      hostel: hostel,
      priceOrFree: priceOrFree.trim(),
      createdAt: DateTime.now(),
    );
    _listings.insert(0, newListing);
    return newListing;
  }

  @override
  Future<void> markAsClaimed(String id) async {
    final index = _listings.indexWhere((l) => l.id == id);
    if (index != -1) {
      final existing = _listings[index];
      _listings[index] = ExchangeListing(
        id: existing.id,
        itemName: existing.itemName,
        description: existing.description,
        condition: existing.condition,
        category: existing.category,
        ownerId: existing.ownerId,
        ownerHandle: existing.ownerHandle,
        hostel: existing.hostel,
        priceOrFree: existing.priceOrFree,
        createdAt: existing.createdAt,
        isAvailable: false,
      );
    }
  }
}
