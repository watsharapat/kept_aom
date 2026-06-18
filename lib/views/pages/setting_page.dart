import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:kept_aom/viewmodels/theme_provider.dart';
import 'package:kept_aom/views/pages/quick_titles_page.dart';
import 'package:kept_aom/views/utils/styles.dart';

class SettingPage extends ConsumerWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: const AppBarGradientBackground(),
        title: const Text('Settings'),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                padding: const EdgeInsets.all(8),
                iconSize: 80,
                color: AppColors.caution,
                icon: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      themeMode == ThemeMode.light
                          ? FontAwesomeIcons.solidSun
                          : FontAwesomeIcons.solidMoon,
                      size: 72,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      themeMode == ThemeMode.light ? 'Light mode' : 'Dark mode',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                onPressed: () {
                  themeNotifier.toggleTheme();
                },
              ),
            ),

            // Quick Title Button
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                padding: const EdgeInsets.all(8),
                iconSize: 80,
                color: AppColors.primary,
                icon: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const FaIcon(FontAwesomeIcons.language, size: 72),
                    const SizedBox(height: 8),
                    Text(
                      'English',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                onPressed: () {},
              ),
            ),

            // Placeholder for additional buttons
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                padding: const EdgeInsets.all(8),
                iconSize: 80,
                color: Colors.cyan,
                icon: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.quickreply_rounded),
                    const SizedBox(height: 8),
                    Text(
                      'Quick Titles',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                onPressed: () {
                  context.push('/quick_titles');
                },
              ),
            ),

            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                padding: const EdgeInsets.all(8),
                iconSize: 80,
                color: Colors.redAccent,
                icon: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const FaIcon(FontAwesomeIcons.piggyBank, size: 72),
                    const SizedBox(height: 8),
                    Text(
                      'Saving Goals',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                onPressed: () {
                  context.push('/savingGoals');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
