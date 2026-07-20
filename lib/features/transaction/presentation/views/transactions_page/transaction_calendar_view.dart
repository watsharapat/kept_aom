import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept_aom/features/transaction/domain/entities/transaction_entity.dart';
import 'package:kept_aom/features/transaction/presentation/viewmodels/transaction_viewmodel.dart';
import 'package:kept_aom/features/transaction/presentation/views/transactions_page/transaction_list_view.dart';
import 'package:kept_aom/core/theme/styles.dart';
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
  late Map<DateTime, List<TransactionEntity>> _groupedTransactions;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateGroupedTransactions();
  }

  void _updateGroupedTransactions() {
    final transactions = ref.watch(transactionViewModelProvider).value ?? [];
    _groupedTransactions = _groupTransactions(transactions);
  }

  Map<DateTime, List<TransactionEntity>> _groupTransactions(
    List<TransactionEntity> transactions,
  ) {
    Map<DateTime, List<TransactionEntity>> groupedTransactions = {};
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

  List<TransactionEntity> _getTransactionsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _groupedTransactions[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    _updateGroupedTransactions();
    final selectedDay = _selectedDay ?? _focusedDay;

    return ListView(
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: AppStyles.cardDecoration(context),
          child: TableCalendar(
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
              markerDecoration: const BoxDecoration(shape: BoxShape.circle),
              markersMaxCount: 5,
              markerSize: 8,
              markerMargin: const EdgeInsets.symmetric(horizontal: 0.5),
              todayDecoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 1),
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
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    events.length > 5 ? 5 : events.length,
                    (idx) {
                      final tx = events[idx] as TransactionEntity;
                      final color = tx.typeId == 1
                          ? AppColors.danger
                          : AppColors.success;
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
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: KeyedSubtree(
            key: ValueKey<String>(selectedDay.toString()),
            child: _buildTransactionList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    final transactions = _getTransactionsForDay(_selectedDay ?? _focusedDay);
    final provider = ref.read(transactionViewModelProvider.notifier);

    if (transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: Text('No transactions for this day')),
      );
    }

    return TransactionDateGroupCard(
      dateStr: FormatUtils.formatDate(_selectedDay ?? _focusedDay),
      transactionsOnDate: transactions,
      provider: provider,
    );
  }
}
