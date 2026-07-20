import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept_aom/features/transaction/presentation/viewmodels/transaction_viewmodel.dart';
import 'package:kept_aom/core/theme/styles.dart';
import 'package:kept_aom/utils/format_utils.dart';

final ascendingProvider = StateProvider<bool>((ref) => false);

class TodayTransactions extends ConsumerWidget {
  const TodayTransactions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionViewModelProvider);
    final ascending = ref.watch(ascendingProvider);

    return transactionsAsync.when(
      data: (transactions) {
        final today = DateTime.now();
        var todayTransactions = transactions.where((transaction) {
          return transaction.date.year == today.year &&
              transaction.date.month == today.month &&
              transaction.date.day == today.day;
        }).toList();

        final todaySum = todayTransactions.fold<double>(
          0,
          (sum, transaction) => sum + transaction.amount,
        );

        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: AppStyles.cardDecoration(context),
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          constraints: const BoxConstraints(minHeight: 250),
          child: todayTransactions.isEmpty
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 50,
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                        top: 16,
                        bottom: 4,
                        left: 16,
                        right: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Today Transactions',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 48,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No transactions for today',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 50,
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                        top: 16,
                        bottom: 4,
                        left: 16,
                        right: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Today Transactions ',
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder:
                                    (Widget child, Animation<double> animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                child: Text(
                                  '(${FormatUtils.formatNumber(todaySum)})',
                                  key: ValueKey<double>(todaySum),
                                  style: Theme.of(context).textTheme.displaySmall
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w400,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(
                              ascending ? Icons.arrow_upward : Icons.arrow_downward,
                            ),
                            onPressed: () {
                              ref.read(ascendingProvider.notifier).state =
                                  !ascending;
                            },
                          ),
                        ],
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 4,
                      ),
                      itemCount: todayTransactions.length,
                      itemBuilder: (context, index) {
                        final actualIndex = ascending
                            ? index
                            : todayTransactions.length - 1 - index;
                        final transaction = todayTransactions[actualIndex];
                        final isLast = index == todayTransactions.length - 1;

                        return Container(
                          decoration: isLast
                              ? null
                              : BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outline.withValues(alpha: 0.2),
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                          child: ListTile(
                            leading: SizedBox(
                              height: 40,
                              width: 40,
                              child: Center(
                                child: Text(
                                  transaction.icon,
                                  style: const TextStyle(
                                    fontFamily: 'NotoEmoji',
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              transaction.title,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            subtitle: transaction.description != ""
                                ? Text(
                                    transaction.description,
                                    style: const TextStyle(fontSize: 12),
                                  )
                                : null,
                            trailing: SizedBox(
                              height: 40,
                              width: 80,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  FormatUtils.formatNumber(transaction.amount),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
