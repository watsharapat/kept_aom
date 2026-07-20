import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kept_aom/features/transaction/domain/entities/transaction_entity.dart';
import 'package:kept_aom/features/dashboard/presentation/views/dashboard_page.dart';
import 'package:kept_aom/features/transaction/presentation/views/edit_transaction_page.dart';
import 'package:kept_aom/features/transaction/presentation/views/add_transaction_page/add_transaction_page.dart';
import 'package:kept_aom/features/home/presentation/views/home_page.dart';
import 'package:kept_aom/features/auth/presentation/views/login_page.dart';
import 'package:kept_aom/features/quick_title/presentation/views/quick_titles_page.dart';
import 'package:kept_aom/features/category/presentation/views/categories_page.dart';
import 'package:kept_aom/features/dashboard/presentation/views/category_transactions_page.dart';
import 'package:kept_aom/features/saving_goal/presentation/views/saving_goals_page.dart';
import 'package:kept_aom/features/dashboard/presentation/views/setting_page.dart';
import 'package:kept_aom/features/auth/presentation/views/account_page.dart';
import 'package:kept_aom/features/transaction/presentation/views/transactions_page/transactions_page.dart';
import 'package:kept_aom/core/widgets/bottom_nav.dart';
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
  categories('/categories'),
  dashboard('/dashboard'),
  categoryTransactions('/categoryTransactions'),
  account('/account');

  final String path;
  const AppRoute(this.path);
}

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
        child: AddTransactionPage(),
        transitionsBuilder: _slideUpTransition,
      ),
    ),
    GoRoute(
      path: AppRoute.editTransaction.path,
      pageBuilder: (context, state) {
        final transaction = state.extra as TransactionEntity;
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
      },
    ),
    GoRoute(
      path: AppRoute.categories.path,
      pageBuilder: (context, state) {
        return const CustomTransitionPage(
          child: CategoriesPage(),
          transitionsBuilder: _slideDownTransition,
        );
      },
    ),
    GoRoute(
      path: AppRoute.account.path,
      pageBuilder: (context, state) {
        return const CustomTransitionPage(
          child: AccountPage(),
          transitionsBuilder: _slideDownTransition,
        );
      },
    ),
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
    BuildContext,
    Animation<double>,
    Animation<double>,
    Widget,
  )
  transitionBuilder,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: transitionBuilder,
  );
}

class ScaffoldWithBottomNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithBottomNavBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: child, bottomNavigationBar: const BottomNavBar());
  }
}

Widget _slideLeftToRightTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final newPageTween = Tween(
    begin: const Offset(-1.0, 0.0),
    end: Offset.zero,
  ).chain(CurveTween(curve: Curves.easeInOut));
  final newPageAnimation = animation.drive(newPageTween);

  final oldPageTween = Tween(
    begin: Offset.zero,
    end: const Offset(1.0, 0.0),
  ).chain(CurveTween(curve: Curves.easeInOut));
  final oldPageAnimation = secondaryAnimation.drive(oldPageTween);

  return SlideTransition(
    position: newPageAnimation,
    child: SlideTransition(
      position: oldPageAnimation,
      child: child,
    ),
  );
}

Widget _slideRightToLeftTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final newPageTween = Tween(
    begin: const Offset(1.0, 0.0),
    end: Offset.zero,
  ).chain(CurveTween(curve: Curves.easeInOut));
  final newPageAnimation = animation.drive(newPageTween);

  final oldPageTween = Tween(
    begin: Offset.zero,
    end: const Offset(-1.0, 0.0),
  ).chain(CurveTween(curve: Curves.easeInOut));
  final oldPageAnimation = secondaryAnimation.drive(oldPageTween);

  return SlideTransition(
    position: newPageAnimation,
    child: SlideTransition(
      position: oldPageAnimation,
      child: child,
    ),
  );
}

Widget _slideUpTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  const begin = Offset(0.0, -1.0);
  const end = Offset.zero;
  const curve = Curves.easeInOut;

  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
  var offsetAnimation = animation.drive(tween);

  return SlideTransition(position: offsetAnimation, child: child);
}

Widget _slideDownTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  const begin = Offset(0.0, 1.0);
  const end = Offset.zero;
  const curve = Curves.easeInOut;

  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
  var offsetAnimation = animation.drive(tween);

  return SlideTransition(position: offsetAnimation, child: child);
}
