import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../providers/partner_request_providers.dart';
import '../widgets/partner_request_card.dart';

class MyPartnerRequestsScreen extends ConsumerWidget {
  const MyPartnerRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myRequestsAsync = ref.watch(myPartnerRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Partner Requests'),
      ),
      body: myRequestsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (requests) {
          if (requests.isEmpty) {
            return EmptyStateView(
              icon: Icons.history_edu_outlined,
              title: 'No Requests Created',
              description: 'You have not posted any partner requests. You can post 1 request per calendar day.',
              actionText: 'Post Request',
              onAction: () => context.push('/create-partner-request'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final req = requests[index];
              return PartnerRequestCard(
                request: req,
                onTap: () => context.push('/partner-request-detail/${req.id}', extra: req),
              );
            },
          );
        },
      ),
    );
  }
}
