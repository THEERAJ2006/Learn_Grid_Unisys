import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'navigation.dart';
import '../../features/shell/app_shell.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/content/screens/content_list_screen.dart';
import '../../features/content/screens/content_viewer_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/ai_assistant/screens/ai_assistant_screen.dart';
import '../../features/gamification/screens/progress_screen.dart';
import '../../features/gamification/screens/leaderboard_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/settings/settings_prefs.dart';
import '../../features/chat/screens/chat_sessions_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/files/screens/file_manager_screen.dart';
import '../../features/files/screens/file_detail_screen.dart';

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  redirect: (context, state) async {
    final hasShown = await SettingsPrefs.getHasShownOnboarding();
    final loggingIn = state.uri.path == '/onboarding';
    if (!hasShown) {
      return '/onboarding';
    }
    if (loggingIn) {
      return '/';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => AppShellScreen(child: child),
      routes: [
        GoRoute(
          path: '/',
          name: 'dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/chat',
          name: 'chat-sessions',
          builder: (context, state) => const ChatSessionsScreen(),
          routes: [
            GoRoute(
              path: 'session/:id',
              name: 'chat-session',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return ChatScreen(sessionId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/files',
          name: 'files',
          builder: (context, state) => const FileManagerScreen(),
          routes: [
            GoRoute(
              path: ':id',
              name: 'file-detail',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return FileDetailScreen(fileId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/content',
      name: 'content-list',
      builder: (context, state) => const ContentListScreen(),
    ),
    GoRoute(
      path: '/content/:id',
      name: 'content-viewer',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ContentViewerScreen(contentId: id);
      },
    ),
    GoRoute(
      path: '/search',
      name: 'search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/assistant',
      name: 'ai-assistant',
      builder: (context, state) => const AIAssistantScreen(),
    ),
    GoRoute(
      path: '/progress',
      name: 'progress',
      builder: (context, state) => const ProgressScreen(),
    ),
    GoRoute(
      path: '/leaderboard',
      name: 'leaderboard',
      builder: (context, state) => const LeaderboardScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Error')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Route not found: ${state.uri}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
);
