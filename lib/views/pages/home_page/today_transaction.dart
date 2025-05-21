import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kept_aom/models/transaction_model.dart';
import 'package:kept_aom/viewmodels/transaction_provider.dart';
import 'package:kept_aom/views/utils/styles.dart';

final ascendingProvider = StateProvider<bool>((ref) => false);

class TodayTransactions extends ConsumerWidget {
  const TodayTransactions({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(transactionProvider);
    List<Transaction> transactions = provider.transactions;
    final ascending = ref.watch(ascendingProvider);

    final today = DateTime.now();
    var todayTransactions = transactions.where((transaction) {
      return transaction.date.year == today.year &&
          transaction.date.month == today.month &&
          transaction.date.day == today.day;
    }).toList();

    // เพิ่ม: เรียงลำดับข้อมูลตาม date
    // todayTransactions.sort((a, b) {
    //   if (ascending) {
    //     return a.date.compareTo(b.date);
    //   } else {
    //     return b.date.compareTo(a.date);
    //   }
    // });

    final todaySum = todayTransactions.fold<double>(
      0,
      (sum, transaction) => sum + transaction.amount,
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
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
      child: todayTransactions.isEmpty
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Container(
                    height: 50,
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                        top: 16, bottom: 4, left: 16, right: 16),
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
                  Expanded(
                    child: Center(
                      child: Text(
                        'No transactions for today',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  )
                ])
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 50,
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                      top: 16, bottom: 4, left: 16, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Today Transactions ',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          Text(
                            '(${todaySum.toStringAsFixed(2)})',
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w400),
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
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 4),
                    itemCount: todayTransactions.length,
                    itemBuilder: (context, index) {
                      //ส่วนนี้คือการ sort แบบไทยบ้าน
                      final actualIndex = ascending
                          ? index
                          : todayTransactions.length - 1 - index;
                      final transaction = todayTransactions[actualIndex];
                      final fullTitle = transaction.title.split(' ');
                      final emoji = fullTitle[0];
                      final title = fullTitle.sublist(1).join(' ');

                      return ListTile(
                        leading: Container(
                          decoration: BoxDecoration(
                            color: Colors.indigo[100],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          clipBehavior: Clip.antiAlias,
                          height: 40,
                          width: 40,
                          child: Center(
                            child: Text(
                              emoji,
                              style: const TextStyle(
                                  fontFamily: 'NotoEmoji', fontSize: 20),
                            ),
                          ),
                        ),
                        title: Text(title),
                        subtitle: Text(
                          DateFormat('EEE, M/d/y').format(transaction.date),
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: SizedBox(
                          height: 40,
                          width: 80,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              transaction.amount.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: transaction.typeId == 1
                                    ? Colors.red[600]
                                    : Colors.green[600],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
