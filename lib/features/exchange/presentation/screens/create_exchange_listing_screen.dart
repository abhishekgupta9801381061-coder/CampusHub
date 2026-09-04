import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/exchange_providers.dart';

class CreateExchangeListingScreen extends ConsumerStatefulWidget {
  const CreateExchangeListingScreen({super.key});

  @override
  ConsumerState<CreateExchangeListingScreen> createState() => _CreateExchangeListingScreenState();
}

class _CreateExchangeListingScreenState extends ConsumerState<CreateExchangeListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController(text: 'Free');

  String _category = AppConstants.exchangeCategories.first;
  String _condition = 'Gently Used';
  bool _isLoading = false;

  final _conditions = ['Brand New', 'Like New', 'Gently Used', 'Fair'];

  @override
  void dispose() {
    _itemNameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(exchangeRepositoryProvider).createListing(
            itemName: _itemNameController.text,
            description: _descController.text,
            condition: _condition,
            category: _category,
            ownerId: user.id,
            ownerHandle: user.handle,
            hostel: user.hostel, // STRICTLY hostel only, zero room number!
            priceOrFree: _priceController.text,
          );

      ref.invalidate(exchangeListingsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item listed on the Cross-Hostel Board!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Academic Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.shield_outlined, color: Color(0xFF2563EB), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Privacy notice: Only your hostel name is shared. Your room number is strictly never collected or shown.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF1E40AF)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Category
              const Text('Category *', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _category,
                isExpanded: true,
                items: AppConstants.exchangeCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _category = val);
                },
              ),
              const SizedBox(height: 16),

              // Condition
              const Text('Condition *', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _condition,
                isExpanded: true,
                items: _conditions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _condition = val);
                },
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: 'Item Name',
                hintText: 'e.g. Thomas Calculus 14th Edition',
                controller: _itemNameController,
                isRequired: true,
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: 'Price / Exchange Preference',
                hintText: 'e.g. Free, ₹200, or Trade for Lab Coat',
                controller: _priceController,
                isRequired: true,
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: 'Description & Notes',
                hintText: 'Mention edition, condition, marks or notes included...',
                controller: _descController,
                maxLines: 4,
                isRequired: true,
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),

              AppButton(
                text: 'Publish Listing',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
