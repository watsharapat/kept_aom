import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kept_aom/viewmodels/transaction_provider.dart';
import 'package:kept_aom/views/pages/home_page/add_transaction_page/add_transaction_page.dart';
import 'package:kept_aom/views/pages/login_page.dart';
import 'package:kept_aom/views/utils/styles.dart';
import 'package:kept_aom/views/widgets/bottom_nav.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kept_aom/models/transaction_model.dart';
import 'package:table_calendar/table_calendar.dart';

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
              leadingWidth: 200,
              leading: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
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
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
                child: Row(
                  children: [
                    // Padding(
                    //     padding: const EdgeInsets.all(4),
                    //     child: Container(
                    //       decoration: BoxDecoration(
                    //           color: AppColors.primary,
                    //           borderRadius:
                    //               const BorderRadius.all(Radius.circular(99))),
                    //       height: 40,
                    //       width: 40,
                    //       child: Icon(
                    //         color: AppColors.lightBackground,
                    //         Icons.receipt_long_rounded,
                    //         size: 24,
                    //       ),
                    //     )),
                    // // ส่วนแสดงข้อความ
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Transactions',
                        style: Theme.of(context).textTheme.displaySmall,
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
                      color: Theme.of(context).cardColor,
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
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
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
                        thickness: 2,
                      ),
                    ),
                    Text(
                      " $dateStr",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(
                        width: 8), // Add spacing between the text and the line
                    const Expanded(
                      flex: 8,
                      child: Divider(
                        color: AppColors.border,
                        thickness: 2,
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
                                  ? AppColors.danger
                                  : AppColors.success),
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

class TransactionCalendarView extends StatefulWidget {
  final List<Transaction> transactions;

  const TransactionCalendarView({super.key, required this.transactions});

  @override
  _TransactionCalendarViewState createState() =>
      _TransactionCalendarViewState();
}

class _TransactionCalendarViewState extends State<TransactionCalendarView> {
  late Map<DateTime, List<Transaction>> _groupedTransactions;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _groupedTransactions = _groupTransactions(widget.transactions);
  }

  Map<DateTime, List<Transaction>> _groupTransactions(
      List<Transaction> transactions) {
    Map<DateTime, List<Transaction>> groupedTransactions = {};
    for (var transaction in transactions) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      ); // Normalize to remove time
      if (groupedTransactions.containsKey(date)) {
        groupedTransactions[date]!.add(transaction);
      } else {
        groupedTransactions[date] = [transaction];
      }
    }
    return groupedTransactions;
  }

  List<Transaction> _getTransactionsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _groupedTransactions[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2000, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: CalendarFormat.month,
          eventLoader: _getTransactionsForDay,
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay; // Update focused day
            });
          },
          calendarStyle: CalendarStyle(
            markerDecoration: BoxDecoration(
              color: TextTheme.of(context).bodyMedium?.color,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primary,
                width: 1,
              ),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _buildTransactionList(),
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    final transactions = _getTransactionsForDay(_selectedDay ?? _focusedDay);

    if (transactions.isEmpty) {
      return const Center(
        child: Text('No transactions for this day'),
      );
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
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
                style: const TextStyle(fontFamily: 'NotoEmoji', fontSize: 20),
              ),
            ),
          ),
          title: Text(title),
          subtitle: Text(
            DateFormat('EEE, M/d/y').format(transaction.date),
            style: const TextStyle(fontSize: 12),
          ),
          trailing: Text(
            transaction.amount.toString(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: transaction.typeId == 1
                  ? AppColors.danger
                  : AppColors.success,
            ),
          ),
        );
      },
    );
  }
}
