import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kept_aom/models/transaction_model.dart';
import 'package:kept_aom/views/pages/dashboard_page/dashboard_page.dart';
import 'package:kept_aom/views/pages/edit_transaction_page.dart';
import 'package:kept_aom/views/pages/home_page/add_transaction_page/add_transaction_page.dart';
import 'package:kept_aom/views/pages/home_page/home_page.dart';
import 'package:kept_aom/views/pages/login_page.dart';
import 'package:kept_aom/views/pages/quick_titles_page.dart';
import 'package:kept_aom/views/pages/dashboard_page/category_transactions_page.dart';
import 'package:kept_aom/views/pages/saving_goals_page.dart';
import 'package:kept_aom/views/pages/setting_page.dart';
import 'package:kept_aom/views/pages/transactions_page/transactions_page.dart';
import 'package:kept_aom/views/widgets/bottom_nav.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AppRoute {
  home('/home'),
  login('/login'),
  transactions('/transactions'),
  settings('/settings'),
  addTransaction('/addtransaction'),
  editTransaction('/editTransaction'),
  savingGoals('/savingGoals'),
  quickTitles('/quick_titles'),
  dashboard('/dashboard'),
  categoryTransactions('/categoryTransactions');

  final String path;
  const AppRoute(this.path);
}

// Map path เป็น index ของ BottomNavBar
final bottomNavIndexMap = {
  AppRoute.home.path: 0,
  AppRoute.transactions.path: 1,
  AppRoute.dashboard.path: 2,
  AppRoute.settings.path: 3,
};

String? lastRoutePath;

final router = GoRouter(
  initialLocation: AppRoute.home.path,
  redirect: (context, state) {
    final user = Supabase.instance.client.auth.currentUser;
    final isLoggingIn = state.matchedLocation == AppRoute.login.path;

    if (user == null && !isLoggingIn) return AppRoute.login.path;
    if (user != null && isLoggingIn) return AppRoute.home.path;

    return null;
  },
  routes: [
    GoRoute(
      path: AppRoute.login.path,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoute.addTransaction.path,
      pageBuilder: (context, state) => const CustomTransitionPage(
          child: AddTransactionPage(), transitionsBuilder: _slideUpTransition),
    ),
    GoRoute(
      path: AppRoute.editTransaction.path,
      pageBuilder: (context, state) {
        final transaction = state.extra as Transaction;
        return CustomTransitionPage(
          child: EditTransactionPage(transaction: transaction),
          transitionsBuilder: _slideLeftToRightTransition,
        );
      },
    ),
    GoRoute(
      path: AppRoute.savingGoals.path,
      pageBuilder: (context, state) {
        return const CustomTransitionPage(
          child: SavingGoalsPage(),
          transitionsBuilder: _slideDownTransition,
        );
      },
    ),
    GoRoute(
        path: AppRoute.quickTitles.path,
        pageBuilder: (context, state) {
          return const CustomTransitionPage(
            child: QuickTitlePage(),
            transitionsBuilder: _slideDownTransition,
          );
        }),
    GoRoute(
      path: AppRoute.categoryTransactions.path,
      pageBuilder: (context, state) {
        final Map<String, dynamic> extras = state.extra as Map<String, dynamic>;
        return CustomTransitionPage(
          child: CategoryTransactionsPage(
            categoryId: extras['categoryId'] as int,
            categoryName: extras['categoryName'] as String,
            categoryIcon: extras['categoryIcon'] as String,
            startDate: extras['startDate'] as DateTime?,
            endDate: extras['endDate'] as DateTime?,
            typeId: extras['typeId'] as int?,
            dateRangeLabel: extras['dateRangeLabel'] as String?,
          ),
          transitionsBuilder: _slideLeftToRightTransition,
        );
      },
    ),
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithBottomNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: AppRoute.home.path,
          pageBuilder: (context, state) {
            final prev = lastRoutePath;
            lastRoutePath = state.fullPath;

            final prevIndex = bottomNavIndexMap[prev ?? ''] ?? 0;
            final currentIndex = bottomNavIndexMap[state.fullPath] ?? 0;

            final transition = (currentIndex > prevIndex)
                ? _slideRightToLeftTransition
                : _slideLeftToRightTransition;

            return buildTransitionPage(
              child: const HomePage(),
              state: state,
              transitionBuilder: transition,
            );
          },
        ),
        GoRoute(
          path: AppRoute.transactions.path,
          pageBuilder: (context, state) {
            final prev = lastRoutePath;
            lastRoutePath = state.fullPath;

            final prevIndex = bottomNavIndexMap[prev ?? ''] ?? 0;
            final currentIndex = bottomNavIndexMap[state.fullPath] ?? 0;

            final transition = (currentIndex > prevIndex)
                ? _slideRightToLeftTransition
                : _slideLeftToRightTransition;

            return buildTransitionPage(
              child: const TransactionsPage(),
              state: state,
              transitionBuilder: transition,
            );
          },
        ),
        GoRoute(
          path: AppRoute.dashboard.path,
          pageBuilder: (context, state) {
            final prev = lastRoutePath;
            lastRoutePath = state.fullPath;

            final prevIndex = bottomNavIndexMap[prev ?? ''] ?? 0;
            final currentIndex = bottomNavIndexMap[state.fullPath] ?? 0;

            final transition = (currentIndex > prevIndex)
                ? _slideRightToLeftTransition
                : _slideLeftToRightTransition;

            return buildTransitionPage(
              child: const DashboardPage(),
              state: state,
              transitionBuilder: transition,
            );
          },
        ),
        GoRoute(
          path: AppRoute.settings.path,
          pageBuilder: (context, state) {
            final prev = lastRoutePath;
            lastRoutePath = state.fullPath;

            final prevIndex = bottomNavIndexMap[prev ?? ''] ?? 0;
            final currentIndex = bottomNavIndexMap[state.fullPath] ?? 0;

            final transition = (currentIndex > prevIndex)
                ? _slideRightToLeftTransition
                : _slideLeftToRightTransition;

            return buildTransitionPage(
              child: const SettingPage(),
              state: state,
              transitionBuilder: transition,
            );
          },
        ),
      ],
    ),
  ],
);

CustomTransitionPage<T> buildTransitionPage<T>({
  required Widget child,
  required GoRouterState state,
  required Widget Function(
          BuildContext, Animation<double>, Animation<double>, Widget)
      transitionBuilder,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: transitionBuilder,
  );
}

// Scaffold ที่มี BottomNavBar
class ScaffoldWithBottomNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithBottomNavBar({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}

// Transition ที่ใช้ในการเปลี่ยนหน้า
// Slide จากซ้ายไปขวา (หน้าใหม่มาทางซ้าย)
Widget _slideLeftToRightTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child) {
  // Tween สำหรับหน้าใหม่ (child)
  final newPageTween = Tween(
    begin: const Offset(-1.0, 0.0),
    end: Offset.zero,
  ).chain(CurveTween(curve: Curves.easeInOut));
  final newPageAnimation = animation.drive(newPageTween);

  // Tween สำหรับหน้าเก่า (secondaryAnimation)
  final oldPageTween = Tween(
    begin: Offset.zero,
    end: const Offset(1.0, 0.0), // เลื่อนหน้าเก่าไปทางขวา
  ).chain(CurveTween(curve: Curves.easeInOut));
  final oldPageAnimation = secondaryAnimation.drive(oldPageTween);

  return SlideTransition(
    position: newPageAnimation, // หน้าใหม่เลื่อนจากซ้ายมา
    child: SlideTransition(
      position: oldPageAnimation, // หน้าเก่าเลื่อนไปทางขวา
      child: child,
    ),
  );
}

// Slide จากขวาไปซ้าย (หน้าใหม่มาทางขวา)
Widget _slideRightToLeftTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child) {
  // Tween สำหรับหน้าใหม่ (child)
  final newPageTween = Tween(
    begin: const Offset(1.0, 0.0),
    end: Offset.zero,
  ).chain(CurveTween(curve: Curves.easeInOut));
  final newPageAnimation = animation.drive(newPageTween);

  // Tween สำหรับหน้าเก่า (secondaryAnimation)
  final oldPageTween = Tween(
    begin: Offset.zero,
    end: const Offset(-1.0, 0.0), // เลื่อนหน้าเก่าไปทางซ้าย
  ).chain(CurveTween(curve: Curves.easeInOut));
  final oldPageAnimation = secondaryAnimation.drive(oldPageTween);

  return SlideTransition(
    position: newPageAnimation, // หน้าใหม่เลื่อนจากขวามา
    child: SlideTransition(
      position: oldPageAnimation, // หน้าเก่าเลื่อนไปทางซ้าย
      child: child,
    ),
  );
}

Widget _slideUpTransition(BuildContext context, Animation<double> animation,
    Animation<double> secondaryAnimation, Widget child) {
  const begin = Offset(0.0, -1.0);
  const end = Offset.zero;
  const curve = Curves.easeInOut;

  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
  var offsetAnimation = animation.drive(tween);

  return SlideTransition(
    position: offsetAnimation,
    child: child,
  );
}

Widget _slideDownTransition(BuildContext context, Animation<double> animation,
    Animation<double> secondaryAnimation, Widget child) {
  const begin = Offset(0.0, 1.0);
  const end = Offset.zero;
  const curve = Curves.easeInOut;

  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
  var offsetAnimation = animation.drive(tween);

  return SlideTransition(
    position: offsetAnimation,
    child: child,
  );
}

Widget _fadeTransition(BuildContext context, Animation<double> animation,
    Animation<double> secondaryAnimation, Widget child) {
  return FadeTransition(
    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
    child: child,
  );
}
