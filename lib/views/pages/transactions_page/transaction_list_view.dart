import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:go_router/go_router.dart';
import 'package:kept_aom/models/transaction_model.dart';
import 'package:kept_aom/viewmodels/transaction_provider.dart';
import 'package:kept_aom/views/utils/styles.dart';
import 'package:kept_aom/utils/format_utils.dart';

class TransactionListView extends ConsumerWidget {
  final int? filterCategoryId;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;
  final int? filterTypeId;

  const TransactionListView({
    super.key,
    this.filterCategoryId,
    this.filterStartDate,
    this.filterEndDate,
    this.filterTypeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var transactions = ref.watch(transactionProvider).transactions;
    if (filterCategoryId != null) {
      transactions = transactions
          .where((t) => t.categoryId == filterCategoryId)
          .toList();
    }
    if (filterTypeId != null) {
      transactions = transactions
          .where((t) => t.typeId == filterTypeId)
          .toList();
    }
    if (filterStartDate != null) {
      transactions = transactions
          .where((t) => !t.date.isBefore(filterStartDate!))
          .toList();
    }
    if (filterEndDate != null) {
      transactions = transactions
          .where((t) => t.date.isBefore(filterEndDate!))
          .toList();
    }
    final provider = ref.read(transactionProvider.notifier);
    // จัดกลุ่มธุรกรรมตามวันที่
    Map<String, List<Transaction>> transactionsByDate = {};
    for (var transaction in transactions) {
      final dateStr = FormatUtils.formatDate(transaction.date);
      if (transactionsByDate.containsKey(dateStr)) {
        transactionsByDate[dateStr]!.add(transaction);
      } else {
        transactionsByDate[dateStr] = [transaction];
      }
    }

    return ListView.builder(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      itemCount: transactionsByDate.length,
      itemBuilder: (context, index) {
        final dateStr = transactionsByDate.keys.toList()[index];
        final transactionsOnDate = transactionsByDate[dateStr]!;
        return TransactionDateGroupCard(
          dateStr: dateStr,
          transactionsOnDate: transactionsOnDate,
          provider: provider,
        );
      },
    );
  }
}

class TransactionDateGroupCard extends StatelessWidget {
  final String dateStr;
  final List<Transaction> transactionsOnDate;
  final TransactionProvider provider;

  const TransactionDateGroupCard({
    super.key,
    required this.dateStr,
    required this.transactionsOnDate,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    double totalIncome = 0.0;
    double totalExpense = 0.0;
    for (var transaction in transactionsOnDate) {
      if (transaction.typeId == 1) {
        totalExpense += transaction.amount.abs();
      } else {
        totalIncome += transaction.amount.abs();
      }
    }
    final netAmount = totalIncome - totalExpense;

    return Container(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      decoration: AppStyles.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicHeight(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    netAmount >= 0
                        ? AppColors.success.withValues(alpha: 0.2)
                        : AppColors.danger.withValues(alpha: 0.2),
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.03),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppStyles.cardRadiusValue),
                  topRight: Radius.circular(AppStyles.cardRadiusValue),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            dateStr,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'รายรับ ',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                            Text(
                              FormatUtils.formatNumber(totalIncome),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'รายจ่าย ',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                            Text(
                              FormatUtils.formatNumber(totalExpense),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      FormatUtils.formatNumber(netAmount),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: netAmount >= 0
                            ? AppColors.success
                            : AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ListView.builder(
            reverse: true,
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactionsOnDate.length,
            itemBuilder: (context, index) {
              final transaction = transactionsOnDate[index];
              final isLast = index == 0;

              return Slidable(
                endActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        context.push('/editTransaction', extra: transaction);
                      },
                      backgroundColor: AppColors.caution,
                      foregroundColor: AppColors.textPrimaryOnDark,
                      icon: Icons.edit,
                    ),
                    SlidableAction(
                      onPressed: (context) {
                        provider.deleteTransaction(transaction);
                        provider.fetchTransactions();
                      },
                      backgroundColor: AppColors.danger,
                      foregroundColor: AppColors.textPrimaryOnDark,
                      icon: Icons.delete,
                    ),
                  ],
                ),
                child: Container(
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
                    subtitle: transaction.description != ''
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
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
