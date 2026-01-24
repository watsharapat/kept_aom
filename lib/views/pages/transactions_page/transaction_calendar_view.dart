import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:kept_aom/models/transaction_model.dart';
import 'package:kept_aom/viewmodels/transaction_provider.dart';
import 'package:kept_aom/views/utils/styles.dart';
import 'package:kept_aom/utils/format_utils.dart';
import 'package:table_calendar/table_calendar.dart';

class TransactionCalendarView extends ConsumerStatefulWidget {
  const TransactionCalendarView({super.key});

  @override
  ConsumerState<TransactionCalendarView> createState() =>
      _TransactionCalendarViewState();
}

class _TransactionCalendarViewState
    extends ConsumerState<TransactionCalendarView> {
  late Map<DateTime, List<Transaction>> _groupedTransactions;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateGroupedTransactions();
  }

  void _updateGroupedTransactions() {
    final transactions = ref.watch(transactionProvider).transactions;
    _groupedTransactions = _groupTransactions(transactions);
  }

  Map<DateTime, List<Transaction>> _groupTransactions(
      List<Transaction> transactions) {
    Map<DateTime, List<Transaction>> groupedTransactions = {};
    for (var transaction in transactions) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
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

  double _getTotalAmountForDay(DateTime day) {
    final txs = _getTransactionsForDay(day);
    double sum = 0.0;
    for (var tx in txs) {
      // สมมติ typeId == 1 คือ outcome, 2 คือ income
      sum += tx.typeId == 1 ? -tx.amount : tx.amount;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    _updateGroupedTransactions();
    final selectedDay = _selectedDay ?? _focusedDay;
    final totalAmount = _getTotalAmountForDay(selectedDay);
    final hasTransactions = _getTransactionsForDay(selectedDay).isNotEmpty;

    return Column(
      children: [
        TableCalendar(
          rowHeight: 40,
          firstDay: DateTime.utc(2000, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: CalendarFormat.month,
          eventLoader: _getTransactionsForDay,
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          calendarStyle: CalendarStyle(
            markerDecoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            markersMaxCount: 5,
            markerSize: 8,
            markerMargin: const EdgeInsets.symmetric(horizontal: 0.5),
            todayDecoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primary,
                width: 1,
              ),
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isEmpty) return null;
              // แสดง dot ตาม type ของแต่ละ transaction
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  events.length > 5 ? 5 : events.length,
                  (idx) {
                    final tx = events[idx] as Transaction;
                    final color = tx.typeId == 1
                        ? AppColors.danger // outcome
                        : AppColors.success; // income
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 0.5),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.netural
                : AppColors.lightBackground,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                  visible: hasTransactions,
                  child: Container(
                    height: 16,
                    width: 16,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: AppColors.lightBackground,
                        width: 1,
                      ),
                      color: totalAmount >= 0
                          ? AppColors.success.withValues(alpha: 0.8)
                          : AppColors.danger.withValues(alpha: 0.8),
                    ),
                  )),
              const SizedBox(width: 8),
              Text(
                FormatUtils.formatDate(selectedDay),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(width: 16),
              Visibility(
                  visible: hasTransactions,
                  child: Text(
                    FormatUtils.formatNumber(totalAmount),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: totalAmount >= 0
                              ? AppColors.success
                              : AppColors.danger,
                        ),
                  )),
            ],
          ),
        ),
        Expanded(
          child: _buildTransactionList(),
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    final transactions = _getTransactionsForDay(_selectedDay ?? _focusedDay);
    final provider = ref.read(transactionProvider.notifier);

    if (transactions.isEmpty) {
      return const Center(
        child: Text('No transactions for this day'),
      );
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];

        return Slidable(
          //key: ValueKey(
          //   '${transaction.userId}_${transaction.date}_${transaction.amount}_${transaction.paymentType}_${transaction.typeId}_${transaction.icon}_${transaction.title}_${transaction.description}'),
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
          child: ListTile(
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
                  transaction.icon,
                  style: const TextStyle(fontFamily: 'NotoEmoji', fontSize: 20),
                ),
              ),
            ),
            title: Text(transaction.title,
                style: Theme.of(context).textTheme.bodyMedium),
            subtitle: Text(
              FormatUtils.formatDate(transaction.date),
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Text(
              FormatUtils.formatNumber(transaction.amount),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: transaction.typeId == 1
                    ? AppColors.danger
                    : AppColors.success,
              ),
            ),
          ),
        );
      },
    );
  }
}
