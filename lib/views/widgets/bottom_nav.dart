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
      case 2:
        context.go('/dashboard');
        break;
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
    const double iconContainerSize = 30;
    const double activeIconContainerSize = 48;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
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
          highlightColor: AppColors.transparent,
          splashColor: AppColors.transparent,
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
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const SizedBox(
                width: iconContainerSize,
                height: iconContainerSize,
                child: Center(
                  child: FaIcon(FontAwesomeIcons.house, size: iconSize),
                ),
              ),
              activeIcon: Container(
                width: activeIconContainerSize,
                height: activeIconContainerSize,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: FaIcon(FontAwesomeIcons.house,
                      size: iconSize, color: Theme.of(context).primaryColor),
                ),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: SizedBox(
                width: iconContainerSize,
                height: iconContainerSize,
                child: Center(
                  child: FaIcon(FontAwesomeIcons.calendarDays, size: iconSize),
                ),
              ),
              activeIcon: Container(
                width: activeIconContainerSize,
                height: activeIconContainerSize,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: FaIcon(FontAwesomeIcons.calendarDays,
                      size: iconSize, color: Theme.of(context).primaryColor),
                ),
              ),
              label: 'Transaction',
            ),
            BottomNavigationBarItem(
              icon: SizedBox(
                width: iconContainerSize,
                height: iconContainerSize,
                child: Center(
                  child: FaIcon(FontAwesomeIcons.chartPie, size: iconSize),
                ),
              ),
              activeIcon: Container(
                width: activeIconContainerSize,
                height: activeIconContainerSize,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: FaIcon(FontAwesomeIcons.chartPie,
                      size: iconSize, color: Theme.of(context).primaryColor),
                ),
              ),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: SizedBox(
                width: iconContainerSize,
                height: iconContainerSize,
                child: Center(
                  child: FaIcon(FontAwesomeIcons.gear, size: iconSize),
                ),
              ),
              activeIcon: Container(
                width: activeIconContainerSize,
                height: activeIconContainerSize,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: FaIcon(FontAwesomeIcons.gear,
                      size: iconSize, color: Theme.of(context).primaryColor),
                ),
              ),
              label: 'Setting',
            ),
          ],
        ),
      ),
    );
  }
}
