import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:kept_aom/models/transaction_model.dart';
import 'package:kept_aom/viewmodels/transaction_provider.dart';
import 'package:kept_aom/views/utils/styles.dart';
import 'package:kept_aom/utils/format_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionListView extends ConsumerWidget {
  const TransactionListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionProvider).transactions;
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
        double amoutEachDay = 0.0;
        for (var transaction in transactionsOnDate) {
          if (transaction.typeId == 1) {
            amoutEachDay -= transaction.amount.abs();
          } else {
            amoutEachDay += transaction.amount.abs();
          }
        }
        String amoutEachDayString = FormatUtils.formatNumber(amoutEachDay);

        return Container(
          clipBehavior: Clip.antiAlias,
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          decoration: AppStyles.cardDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    const Expanded(
                      flex: 1,
                      child: Divider(
                        color: AppColors.border,
                        thickness: 1,
                      ),
                    ),
                    Container(
                      decoration: AppStyles.pillDecoration(context),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.mapPin,
                            size: 16,
                            color: amoutEachDay >= 0
                                ? AppColors.success.withValues(alpha: 0.8)
                                : AppColors.danger.withValues(alpha: 0.8),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            dateStr,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            amoutEachDayString,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: amoutEachDay >= 0
                                          ? AppColors.success
                                          : AppColors.danger,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    const Expanded(
                      flex: 1,
                      child: Divider(
                        color: AppColors.border,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                reverse: true,
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactionsOnDate.length,
                itemBuilder: (context, index) {
                  final transaction = transactionsOnDate[index];
                  return Slidable(
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) {
                              context.push('/editTransaction',
                                  extra: transaction);
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
                      child: ListTile(
                        leading: Container(
                          height: 40,
                          width: 40,
                          child: Center(
                            child: Text(
                              transaction.icon,
                              style: const TextStyle(
                                  fontFamily: 'NotoEmoji', fontSize: 24),
                            ),
                          ),
                        ),
                        title: Text(transaction.title,
                            style: Theme.of(context).textTheme.bodyMedium),
                        subtitle: transaction.description != ""
                            ? Text(
                                transaction.description,
                                style: const TextStyle(fontSize: 12),
                              )
                            : null,
                        trailing: Container(
                          height: 40,
                          width: 80,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              FormatUtils.formatNumber(transaction.amount),
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: transaction.typeId == 1
                                      ? AppColors.danger
                                      : AppColors.success),
                            ),
                          ),
                        ),
                      ));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
