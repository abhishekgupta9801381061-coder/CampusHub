import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/achievements/presentation/screens/achievements_screen.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/confessions/presentation/screens/confessions_screen.dart';
import '../../features/contests/domain/contest.dart';
import '../../features/contests/presentation/screens/contest_detail_screen.dart';
import '../../features/contests/presentation/screens/contests_screen.dart';
import '../../features/exchange/presentation/screens/create_exchange_listing_screen.dart';
import '../../features/exchange/presentation/screens/exchange_screen.dart';
import '../../features/groups/domain/group.dart';
import '../../features/groups/presentation/screens/create_group_screen.dart';
import '../../features/groups/presentation/screens/group_detail_screen.dart';
import '../../features/groups/presentation/screens/groups_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/partner_requests/domain/partner_request.dart';
import '../../features/partner_requests/presentation/screens/create_partner_request_screen.dart';
import '../../features/partner_requests/presentation/screens/my_partner_requests_screen.dart';
import '../../features/partner_requests/presentation/screens/partner_request_detail_screen.dart';
import '../../features/partner_requests/presentation/screens/partner_requests_screen.dart';
import '../../features/profile/presentation/screens/discover_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import 'scaffold_with_navbar.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    redirect: (context, state) {
      final isAuthLoading = authState.isLoading;
      if (isAuthLoading) return null;

      final user = authState.value;
      final isLoggingIn = state.matchedLocation == '/auth' || state.matchedLocation == '/forgot-password';

      if (user == null && !isLoggingIn) {
        return '/auth';
      }
      if (user != null && isLoggingIn) {
        return '/home';
      }
      return null;
    },
    routes: [
      // Authentication
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Stateful Bottom Navigation Tabs
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavbar(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Branch 1: Discover
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/discover',
                builder: (context, state) => const DiscoverScreen(),
              ),
            ],
          ),
          // Branch 2: Groups
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/groups',
                builder: (context, state) => const GroupsScreen(),
              ),
            ],
          ),
          // Branch 3: Contests
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/contests',
                builder: (context, state) => const ContestsScreen(),
              ),
            ],
          ),
          // Branch 4: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Feature Detail & Form Routes
      GoRoute(
        path: '/partner-requests',
        builder: (context, state) => const PartnerRequestsScreen(),
      ),
      GoRoute(
        path: '/create-partner-request',
        builder: (context, state) => const CreatePartnerRequestScreen(),
      ),
      GoRoute(
        path: '/my-partner-requests',
        builder: (context, state) => const MyPartnerRequestsScreen(),
      ),
      GoRoute(
        path: '/partner-request-detail/:id',
        builder: (context, state) {
          final req = state.extra as PartnerRequest?;
          final id = state.pathParameters['id'] ?? '';
          return PartnerRequestDetailScreen(requestId: id, initialRequest: req);
        },
      ),
      GoRoute(
        path: '/create-group',
        builder: (context, state) => const CreateGroupScreen(),
      ),
      GoRoute(
        path: '/group-detail/:id',
        builder: (context, state) {
          final group = state.extra as Group?;
          final id = state.pathParameters['id'] ?? '';
          return GroupDetailScreen(groupId: id, initialGroup: group);
        },
      ),
      GoRoute(
        path: '/contest-detail/:id',
        builder: (context, state) {
          final contest = state.extra as Contest;
          return ContestDetailScreen(contest: contest);
        },
      ),
      GoRoute(
        path: '/confessions',
        builder: (context, state) => const ConfessionsScreen(),
      ),
      GoRoute(
        path: '/exchange',
        builder: (context, state) => const ExchangeScreen(),
      ),
      GoRoute(
        path: '/create-exchange',
        builder: (context, state) => const CreateExchangeListingScreen(),
      ),
      GoRoute(
        path: '/achievements',
        builder: (context, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
