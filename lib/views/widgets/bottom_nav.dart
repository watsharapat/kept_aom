import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:kept_aom/views/utils/styles.dart';

// Provider สำหรับเก็บ index ของ bottom nav
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({super.key});

  void _onItemTapped(BuildContext context, WidgetRef ref, int index) {
    final currentIndex = ref.read(bottomNavIndexProvider);
    if (index == currentIndex) return;

    ref.read(bottomNavIndexProvider.notifier).state = index;

    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/transactions');
        break;
      // case 2:
      //   context.go('/dashboard');
      //   break;
      case 3:
        context.go('/settings');
        break;
      default:
        return;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    const double iconSize = 24;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        boxShadow: [
          BoxShadow(
            color: AppColors.overlay.withAlpha(50),
            blurRadius: 32,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: currentIndex,
          onTap: (index) => _onItemTapped(context, ref, index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Theme.of(context).disabledColor,
          backgroundColor: Theme.of(context).cardTheme.color,
          iconSize: 30,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: SizedBox(
                  width: 30,
                  height: 30,
                  child: Center(
                    child: FaIcon(FontAwesomeIcons.house, size: iconSize),
                  ),
                ),
                label: 'Home'),
            BottomNavigationBarItem(
                icon: SizedBox(
                  width: 30,
                  height: 30,
                  child: Center(
                    child:
                        FaIcon(FontAwesomeIcons.calendarDays, size: iconSize),
                  ),
                ),
                label: 'Transaction'),
            BottomNavigationBarItem(
                icon: SizedBox(
                  width: 30,
                  height: 30,
                  child: Center(
                    child: FaIcon(FontAwesomeIcons.chartPie, size: iconSize),
                  ),
                ),
                label: 'Dashboard'),
            BottomNavigationBarItem(
                icon: SizedBox(
                  width: 30,
                  height: 30,
                  child: Center(
                    child: FaIcon(FontAwesomeIcons.gear, size: iconSize),
                  ),
                ),
                label: 'Setting'),
          ],
        ),
      ),
    );
  }
}
