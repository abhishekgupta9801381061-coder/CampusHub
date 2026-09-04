import 'package:equatable/equatable.dart';

class ExchangeListing extends Equatable {
  final String id;
  final String itemName;
  final String description;
  final String condition; // 'Like New', 'Gently Used', 'Fair'
  final String category;
  final String ownerId;
  final String ownerHandle;
  final String hostel; // NEVER room number!
  final String priceOrFree; // 'Free' or '₹150'
  final DateTime createdAt;
  final bool isAvailable;

  const ExchangeListing({
    required this.id,
    required this.itemName,
    required this.description,
    required this.condition,
    required this.category,
    required this.ownerId,
    required this.ownerHandle,
    required this.hostel,
    required this.priceOrFree,
    required this.createdAt,
    this.isAvailable = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_name': itemName,
      'description': description,
      'condition': condition,
      'category': category,
      'owner_id': ownerId,
      'owner_handle': ownerHandle,
      'hostel': hostel,
      'price_or_free': priceOrFree,
      'created_at': createdAt.toIso8601String(),
      'is_available': isAvailable,
    };
  }

  factory ExchangeListing.fromJson(Map<String, dynamic> json) {
    return ExchangeListing(
      id: json['id'] as String,
      itemName: json['item_name'] as String,
      description: json['description'] as String,
      condition: json['condition'] as String,
      category: json['category'] as String,
      ownerId: json['owner_id'] as String,
      ownerHandle: json['owner_handle'] as String,
      hostel: json['hostel'] as String,
      priceOrFree: json['price_or_free'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isAvailable: json['is_available'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        id,
        itemName,
        description,
        condition,
        category,
        ownerId,
        ownerHandle,
        hostel,
        priceOrFree,
        createdAt,
        isAvailable,
      ];
}
