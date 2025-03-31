import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kept_aom/viewmodels/transaction_provider.dart';
import 'package:kept_aom/views/pages/home_page/add_transaction_page/add_transaction_page.dart';
import 'package:kept_aom/views/pages/login_page.dart';
import 'package:kept_aom/views/widgets/bottom_nav.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kept_aom/models/transaction_model.dart';

class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(transactionProvider);
    final user = Supabase.instance.client.auth.currentUser;
    final fullName = user?.userMetadata?['full_name'];
    final firstName = fullName.split(' ')[0];

    return DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Scaffold(
            extendBodyBehindAppBar: false,
            appBar: AppBar(
              forceMaterialTransparency: true,
              toolbarHeight: 80,
              leadingWidth: 250,
              leading: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                margin: const EdgeInsets.only(
                    left: 16, right: 16, top: 4, bottom: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
                child: Row(
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(4),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(99))),
                          height: 40,
                          width: 40,
                          child: Icon(
                            color: Colors.indigo.shade600,
                            Icons.receipt_long_rounded,
                            size: 24,
                          ),
                        )),
                    // ส่วนแสดงข้อความ
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Transactions',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              actions: [
                Container(
                    height: 60,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(99),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.only(
                        left: 16, right: 16, top: 4, bottom: 16),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                    child: const TabBar(
                      labelColor: Colors.indigo,
                      unselectedLabelColor: Colors.grey,
                      indicator: BoxDecoration(),
                      dividerHeight: 0,
                      dividerColor: Colors.transparent,
                      tabs: <Widget>[
                        Tab(
                          icon: Icon(Icons.list),
                          //text: 'List',
                        ),
                        Tab(
                          icon: Icon(Icons.calendar_month_rounded),
                          //text: 'Calendar',
                        ),
                      ],
                    )),
              ],
            ),
            body: TabBarView(children: [
              TransactionListView(
                transactions: provider.transactions,
              ),
              TransactionCalendarView(transactions: provider.transactions)
            ])));
  }
}

class TransactionListView extends StatelessWidget {
  final List<Transaction> transactions;

  const TransactionListView({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
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
        color: Colors.white,
        borderRadius: BorderRadius.only(
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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                color: Colors.indigo,
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                child: Center(
                  child: Text(
                    dateStr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: Container(
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
                                  : Colors.green[600]),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class TransactionCalendarView extends StatelessWidget {
  final List<Transaction> transactions;
  const TransactionCalendarView({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Calendar here soon'),
    );
  }
}
