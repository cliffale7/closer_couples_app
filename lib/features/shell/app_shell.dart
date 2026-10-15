import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../discover/discover_screen.dart';
import '../library/library_screen.dart';
import '../our_story/our_story_screen.dart';
import '../settings/settings_screen.dart';
import '../tonight/tonight_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final pages = const [
      TonightScreen(),
      DiscoverScreen(),
      OurStoryScreen(),
      LibraryScreen(),
      SettingsScreen(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          if (app.activeProfile != null)
            PopupMenuButton<String>(
              tooltip: 'Switch profile. This organizes notes. It is not a lock.',
              onSelected: (value) {
                app.setActiveProfile(value);
              },
              itemBuilder: (context) => [
                for (final profile in app.profiles)
                  PopupMenuItem(
                    value: profile.id,
                    child: Text(profile.displayLabel),
                  ),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    app.activeProfile!.displayLabel,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.nights_stay_outlined), label: 'Tonight'),
          NavigationDestination(icon: Icon(Icons.explore_outlined), label: 'Discover'),
          NavigationDestination(icon: Icon(Icons.auto_stories_outlined), label: 'Our Story'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Library'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}

const _titles = ['Tonight', 'Discover', 'Our Story', 'Library', 'Settings'];
