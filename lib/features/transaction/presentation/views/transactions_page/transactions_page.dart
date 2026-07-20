import 'package:flutter/material.dart';
import 'package:kept_aom/features/transaction/presentation/views/transactions_page/transaction_calendar_view.dart';
import 'package:kept_aom/features/transaction/presentation/views/transactions_page/transaction_list_view.dart';
import 'package:kept_aom/core/theme/styles.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: const AppBarGradientBackground(),
          title: const Text('Transactions'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(42),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              child: Container(
                height: 34,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.all(3),
                  splashBorderRadius: BorderRadius.circular(9),
                  overlayColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.pressed)) {
                      return Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.10);
                    }
                    if (states.contains(WidgetState.hovered) ||
                        states.contains(WidgetState.focused)) {
                      return Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.06);
                    }
                    return Colors.transparent;
                  }),
                  dividerColor: Colors.transparent,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant,
                  indicator: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  tabs: const <Widget>[
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.format_list_bulleted_rounded, size: 16),
                          SizedBox(width: 6),
                          Text('List'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_month_rounded, size: 16),
                          SizedBox(width: 6),
                          Text('Calendar'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: const Padding(
          padding: EdgeInsets.only(top: 6),
          child: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [TransactionListView(), TransactionCalendarView()],
          ),
        ),
      ),
    );
  }
}
