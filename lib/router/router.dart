import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kept_aom/views/pages/home_page/add_transaction_page/add_transaction_page.dart';
import 'package:kept_aom/views/pages/home_page/home_page.dart';
import 'package:kept_aom/views/pages/login_page.dart';
import 'package:kept_aom/views/pages/transactions_page/transactions_page.dart';
import 'package:kept_aom/views/widgets/bottom_nav.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final router = GoRouter(
  initialLocation: '/home',
  redirect: (context, state) {
    final user = Supabase.instance.client.auth.currentUser;
    final isLoggingIn = state.matchedLocation == '/login';

    if (user == null && !isLoggingIn) return '/login';
    if (user != null && isLoggingIn) return '/home';

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/addtransaction',
      pageBuilder: (context, state) => const CustomTransitionPage(
          child: AddTransactionPage(),
          transitionsBuilder: _slideDownTransition),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithBottomNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/transactions',
          builder: (context, state) => const TransactionsPage(),
        ),
        // Add other routes here
      ],
    ),
  ],
);

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

//Trastiion ที่ใช้ในการเปลี่ยนหน้า
Widget _slideFromLeftTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child) {
  const begin = Offset(-1.0, 0.0);
  const end = Offset.zero;
  const curve = Curves.easeInOut;

  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
  var offsetAnimation = animation.drive(tween);

  return SlideTransition(
    position: offsetAnimation,
    child: child,
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
