import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kept_aom/features/transaction/domain/entities/transaction_entity.dart';
import 'package:kept_aom/features/transaction/presentation/viewmodels/transaction_viewmodel.dart';
import 'package:kept_aom/features/home/presentation/views/today_transaction.dart';
import 'package:kept_aom/features/auth/presentation/views/login_page.dart';
import 'package:kept_aom/core/theme/styles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kept_aom/features/saving_goal/presentation/viewmodels/saving_goal_viewmodel.dart';
import 'package:kept_aom/features/saving_goal/presentation/widgets/add_money_saving_goal_bottom_sheet.dart';
import 'package:kept_aom/features/home/presentation/viewmodels/home_viewmodel.dart';

import 'package:kept_aom/utils/constants.dart';
import 'package:kept_aom/utils/format_utils.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionViewModelProvider);
    final transactions = transactionsAsync.value ?? [];
    final isMonthly = ref.watch(monthlyBalanceToggleProvider);
    final savingGoalsAsync = ref.watch(savingGoalViewModelProvider);
    final savingGoals = savingGoalsAsync.value ?? [];
    
    final user = Supabase.instance.client.auth.currentUser;
    final profileImageUrl = user?.userMetadata?['avatar_url'];
    final fullName = user?.userMetadata?['full_name'] ?? 'User';
    final firstName = fullName.split(' ')[0];

    final double balance;
    if (isMonthly) {
      final now = DateTime.now();
      final DateTime cycleStartDate;
      final DateTime cycleEndDate;

      if (now.day >= AppConstants.startDayOfMonth) {
        cycleStartDate = DateTime(
          now.year,
          now.month,
          AppConstants.startDayOfMonth,
        );
        cycleEndDate = DateTime(
          now.year,
          now.month + 1,
          AppConstants.startDayOfMonth,
        );
      } else {
        cycleStartDate = DateTime(
          now.year,
          now.month - 1,
          AppConstants.startDayOfMonth,
        );
        cycleEndDate = DateTime(
          now.year,
          now.month,
          AppConstants.startDayOfMonth,
        );
      }

      final monthlyTransactions = transactions.where((t) {
        return t.date.isAfter(
              cycleStartDate.subtract(const Duration(seconds: 1)),
            ) &&
            t.date.isBefore(cycleEndDate);
      });

      balance = monthlyTransactions.fold<double>(
        0,
        (sum, transaction) => sum + _signedBalanceAmount(transaction),
      );
    } else {
      balance = transactions.fold<double>(
        0,
        (sum, transaction) => sum + _signedBalanceAmount(transaction),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        flexibleSpace: const AppBarGradientBackground(),
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            tooltip: 'Sign out',
            padding: EdgeInsets.zero,
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
            icon: CircleAvatar(
              radius: 16,
              backgroundImage: profileImageUrl != null
                  ? NetworkImage(profileImageUrl)
                  : null,
              child: profileImageUrl == null
                  ? const Icon(Icons.account_circle, size: 28)
                  : null,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Welcome back',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(firstName, overflow: TextOverflow.ellipsis),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton.filledTonal(
              tooltip: 'Refresh transactions',
              onPressed: () {
                ref.read(transactionViewModelProvider.notifier).fetchTransactions();
              },
              icon: const Icon(Icons.replay_outlined),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            accountCard(context, balance, isMonthly, () {
              ref.read(monthlyBalanceToggleProvider.notifier).toggle();
            }),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Saving Goals',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.push('/savingGoals');
                        },
                        child: const Text('See all'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (savingGoals.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'No saving goals yet.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).disabledColor,
                          ),
                    ),
                  )
                else
                  SizedBox(
                    height: 130,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: savingGoals.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final goal = savingGoals[index];
                        final emoji = goal.name.isNotEmpty
                            ? goal.name.characters.first
                            : "🎯";
                        final name = goal.name.characters.skip(1).toString().trim();

                        return GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => AddMoneySavingGoalBottomSheet(
                                goalName: name,
                                goalEmoji: emoji,
                                onSubmit: (addedAmount) {
                                  final transaction = TransactionEntity(
                                    id: null,
                                    userId: Supabase.instance.client.auth
                                        .currentUser!.id,
                                    date: DateTime.now(),
                                    amount: addedAmount.toDouble(),
                                    paymentType: 0,
                                    typeId: 1,
                                    icon: emoji,
                                    title: 'Save to $name',
                                    categoryId: 0,
                                    description:
                                        'Auto-generated saving transaction',
                                  );
                                  ref
                                      .read(transactionViewModelProvider.notifier)
                                      .addTransaction(transaction);

                                  ref.read(savingGoalViewModelProvider.notifier).updateSavingGoal(
                                        goal.name,
                                        goal,
                                      );
                                },
                              ),
                            );
                          },
                          child: Container(
                            width: 140,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: Opacity(
                                      opacity: 0.2,
                                      child: Text(
                                        emoji,
                                        style: const TextStyle(fontSize: 64),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name.isEmpty ? 'Goal' : name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const Spacer(),
                                      Text(
                                        '${FormatUtils.formatNumber(goal.stored.toDouble())} / ${FormatUtils.formatNumber(goal.target.toDouble())}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        bottom: Radius.circular(16)),
                                    child: LinearProgressIndicator(
                                      value: (goal.target > 0)
                                          ? (goal.stored / goal.target)
                                              .clamp(0.0, 1.0)
                                          : 0.0,
                                      minHeight: 6,
                                      backgroundColor:
                                          AppColors.border.withValues(alpha: 0.1),
                                      valueColor: const AlwaysStoppedAnimation<Color>(
                                        AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const TodayTransactions(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        isExtended: true,
        onPressed: () {
          context.push('/addtransaction');
        },
        label: Text(
          'Add Transaction',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        icon: const Icon(Icons.add, size: 24),
      ),
    );
  }

  Widget accountCard(
    BuildContext context,
    double balance,
    bool isMonthly,
    VoidCallback onToggle,
  ) {
    String balanceString = FormatUtils.formatNumber(balance.toDouble());
    return Container(
      clipBehavior: Clip.antiAlias,
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          center: Alignment.bottomRight,
          radius: 3,
          colors: [Color(0xFF3F51B5), Colors.black87],
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Current Account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isMonthly) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'This Month',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Balance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  balanceString,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: IconButton(
              onPressed: onToggle,
              icon: Icon(
                isMonthly ? Icons.calendar_month : Icons.account_balance_wallet,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              tooltip: isMonthly
                  ? 'Show All Time Balance'
                  : 'Show Monthly Balance',
            ),
          ),
        ],
      ),
    );
  }
}

double _signedBalanceAmount(TransactionEntity transaction) {
  final amount = transaction.amount.abs();
  return transaction.typeId == 1 ? -amount : amount;
}
