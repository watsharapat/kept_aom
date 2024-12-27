import 'package:drop_shadow/drop_shadow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kept_aom/views/pages/home_page/home_page.dart';
import 'package:kept_aom/viewmodels/login_provider.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withValues(alpha: 1),
              Theme.of(context).primaryColor.withValues(alpha: 0.4),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo or App Icon
                    // DropShadow(
                    //     child:
                    //     Image.asset(
                    //       'lib/assets/images/coin.png',
                    //       width: 200,
                    //       height: 200,
                    //     ),
                    //     ),
                    SvgPicture.asset(
                      'lib/assets/images/piggy.svg',
                      width: 180,
                      height: 180,
                    ),
                    //const SizedBox(height: 32),

                    const SizedBox(height: 32),
                    Text(
                      'KEPTAOM',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'The personal saving app',
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      'Please sign in to continue.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                    ),
                    const SizedBox(height: 12),

                    // Login State Handler
                    loginState.when(
                      data: (_) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: _buildGoogleLoginButton(context, ref),
                      ),
                      loading: () => const CircularProgressIndicator(
                        strokeWidth: 6,
                        strokeCap: StrokeCap.round,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      error: (error, stackTrace) =>
                          _buildErrorState(context, ref, error),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleLoginButton(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: Theme.of(context).elevatedButtonTheme.style,
        onPressed: () async {
          final success =
              await ref.read(loginProvider.notifier).signInWithGoogle();
          if (success && context.mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'http://pngimg.com/uploads/google/google_PNG19635.png',
              width: 30,
              height: 30,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 12),
            Text(
              'Continue with Google',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Error',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.red.withOpacity(0.8),
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => ref.invalidate(loginProvider),
          style: Theme.of(context).elevatedButtonTheme.style,
          icon: const Icon(Icons.refresh),
          label: const Text('Try again'),
        ),
      ],
    );
  }
}
