import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kept_aom/models/transaction_model.dart';
import 'package:kept_aom/viewmodels/transaction_provider.dart';
import 'package:kept_aom/views/utils/styles.dart';
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
      final dateStr = DateFormat('MMM d, yyyy').format(transaction.date);
      if (transactionsByDate.containsKey(dateStr)) {
        transactionsByDate[dateStr]!.add(transaction);
      } else {
        transactionsByDate[dateStr] = [transaction];
      }
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.only(left: 16, right: 16),
      child: ListView.builder(
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
          String amoutEachDayString =
              NumberFormat("#,##0.00").format(amoutEachDay);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                //color: AppColors.primary,
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
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.netural
                            : AppColors.lightBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
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
                          // Container(
                          //   height: 16,
                          //   width: 16,
                          //   decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(99),
                          //     border: Border.all(
                          //       color: AppColors.lightBackground,
                          //       width: 1,
                          //     ),
                          //     color: amoutEachDay >= 0
                          //         ? AppColors.success.withValues(alpha: 0.8)
                          //         : AppColors.danger.withValues(alpha: 0.8),
                          //   ),
                          // ),
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
                      //key: ValueKey(
                      //   '${transaction.userId}_${transaction.date}_${transaction.amount}_${transaction.paymentType}_${transaction.typeId}_${transaction.icon}_${transaction.title}_${transaction.description}'),
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
                          subtitle: Text(
                              transaction.description == ""
                                  ? 'No details'
                                  : transaction.description,
                              style: Theme.of(context).textTheme.bodySmall),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 80,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    transaction.amount.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: transaction.typeId == 1
                                            ? AppColors.danger
                                            : AppColors.success),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80,
                                height: 24,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    DateFormat('hh:mm a')
                                        .format(transaction.date),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          )));
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
