import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kept_aom/core/theme/styles.dart';
import 'package:kept_aom/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:kept_aom/features/auth/presentation/viewmodels/auth_viewmodel.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).getCurrentUser();
    final fullName = user?.name ?? 'Unknown User';
    final profileImageUrl = user?.avatarUrl;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: const AppBarGradientBackground(),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Account'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  backgroundImage: profileImageUrl != null ? NetworkImage(profileImageUrl) : null,
                  child: profileImageUrl == null
                      ? Icon(
                          Icons.person_rounded,
                          size: 60,
                          color: Theme.of(context).primaryColor,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                fullName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                user?.email ?? 'No email available',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPlaceholder,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                label: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        titleTextStyle: TextTheme.of(context).bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                        contentTextStyle: TextTheme.of(context).bodyMedium,
                        backgroundColor: Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyMedium!.color,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop(); // Close dialog
                              await ref.read(authViewModelProvider.notifier).signOut();
                              if (context.mounted) {
                                context.go('/login');
                              }
                            },
                            child: const Text(
                              'Logout',
                              style: TextStyle(color: AppColors.danger),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
