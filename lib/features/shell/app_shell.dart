import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShellScreen extends StatelessWidget {
  const AppShellScreen({
    super.key,
    required this.child,
  });

  final Widget child;

  int _selectedIndex(String path) {
    if (path.startsWith('/chat')) return 1;
    if (path.startsWith('/files')) return 2;
    if (path.startsWith('/settings')) return 3;
    return 0;
  }

  void _go(BuildContext context, int index) {
    switch (index) {
      case 1:
        context.go('/chat');
        return;
      case 2:
        context.go('/files');
        return;
      case 3:
        context.go('/settings');
        return;
      default:
        context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final selected = _selectedIndex(path);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected,
        onDestinationSelected: (index) => _go(context, index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder), label: 'Files'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
