import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kept_aom/viewmodels/transaction_provider.dart';
import 'package:kept_aom/utils/constants.dart';

enum DashboardPeriod { monthly, quarterly, yearly }

extension DashboardPeriodLabel on DashboardPeriod {
  String get label {
    switch (this) {
      case DashboardPeriod.monthly:
        return 'Month';
      case DashboardPeriod.quarterly:
        return 'Quarter';
      case DashboardPeriod.yearly:
        return 'Year';
    }
  }
}

class CategorySummary {
  final int categoryId;
  final double totalAmount;
  final double percentage;
  final int transactionCount;

  CategorySummary({
    required this.categoryId,
    required this.totalAmount,
    required this.percentage,
    required this.transactionCount,
  });
}

class DashboardDateRange {
  final DateTime startDate;
  final DateTime endDate;

  const DashboardDateRange({required this.startDate, required this.endDate});
}

class DashboardState {
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final double previousTotalBalance;
  final double? balanceChangePercentage;
  final List<CategorySummary> expenseSummaries;
  final List<CategorySummary> incomeSummaries;
  final DateTime cycleStartDate;
  final DateTime cycleEndDate;

  DashboardState({
    this.totalBalance = 0.0,
    this.totalIncome = 0.0,
    this.totalExpense = 0.0,
    this.previousTotalBalance = 0.0,
    this.balanceChangePercentage,
    this.expenseSummaries = const [],
    this.incomeSummaries = const [],
    required this.cycleStartDate,
    required this.cycleEndDate,
  });
}

final dashboardPeriodProvider = StateProvider.autoDispose<DashboardPeriod>(
  (ref) => DashboardPeriod.monthly,
);

final dashboardAnchorDateProvider = StateProvider.autoDispose<DateTime>(
  (ref) => DateTime.now(),
);

final dashboardProvider = Provider<DashboardState>((ref) {
  try {
    final transactionState = ref.watch(transactionProvider);
    final transactions = transactionState.transactions;
    final period = ref.watch(dashboardPeriodProvider);
    final anchorDate = ref.watch(dashboardAnchorDateProvider);

    final range = _dateRangeFor(period, anchorDate);
    final cycleStartDate = range.startDate;
    final cycleEndDate = range.endDate;
    final previousRange = _previousDateRangeFor(period, range);

    double income = 0.0;
    double expense = 0.0;
    double previousIncome = 0.0;
    double previousExpense = 0.0;
    Map<int, double> expenseTotals = {};
    Map<int, int> expenseCounts = {};
    Map<int, double> incomeTotals = {};
    Map<int, int> incomeCounts = {};

    for (var transaction in transactions) {
      final date = transaction.date;
      final amount = transaction.amount.abs();
      final isCurrentPeriod = _isInDateRange(date, range);
      final isPreviousPeriod = _isInDateRange(date, previousRange);

      if (!isCurrentPeriod && !isPreviousPeriod) {
        continue;
      }

      if (transaction.typeId == 2) {
        if (isCurrentPeriod) {
          income += amount;
          final currentTotal = incomeTotals[transaction.categoryId] ?? 0.0;
          incomeTotals[transaction.categoryId] = currentTotal + amount;

          final currentCount = incomeCounts[transaction.categoryId] ?? 0;
          incomeCounts[transaction.categoryId] = currentCount + 1;
        } else if (isPreviousPeriod) {
          previousIncome += amount;
        }
      } else if (transaction.typeId == 1) {
        if (isCurrentPeriod) {
          expense += amount;
          final currentTotal = expenseTotals[transaction.categoryId] ?? 0.0;
          expenseTotals[transaction.categoryId] = currentTotal + amount;

          final currentCount = expenseCounts[transaction.categoryId] ?? 0;
          expenseCounts[transaction.categoryId] = currentCount + 1;
        } else if (isPreviousPeriod) {
          previousExpense += amount;
        }
      }
    }

    // Calculate summaries
    final List<CategorySummary> expenseSummaries = [];
    expenseTotals.forEach((categoryId, amount) {
      double percentage = 0.0;
      if (expense != 0) {
        percentage = (amount / expense) * 100;
      }
      expenseSummaries.add(
        CategorySummary(
          categoryId: categoryId,
          totalAmount: amount,
          percentage: percentage,
          transactionCount: expenseCounts[categoryId] ?? 0,
        ),
      );
    });
    expenseSummaries.sort(
      (a, b) => b.totalAmount.abs().compareTo(a.totalAmount.abs()),
    );

    final List<CategorySummary> incomeSummaries = [];
    incomeTotals.forEach((categoryId, amount) {
      double percentage = 0.0;
      if (income != 0) {
        percentage = (amount / income) * 100;
      }
      incomeSummaries.add(
        CategorySummary(
          categoryId: categoryId,
          totalAmount: amount,
          percentage: percentage,
          transactionCount: incomeCounts[categoryId] ?? 0,
        ),
      );
    });
    incomeSummaries.sort(
      (a, b) => b.totalAmount.abs().compareTo(a.totalAmount.abs()),
    );

    final totalBalance = income - expense;
    final previousTotalBalance = previousIncome - previousExpense;

    return DashboardState(
      totalBalance: totalBalance,
      totalIncome: income,
      totalExpense: expense,
      previousTotalBalance: previousTotalBalance,
      balanceChangePercentage: _calculateChangePercentage(
        totalBalance,
        previousTotalBalance,
      ),
      expenseSummaries: expenseSummaries,
      incomeSummaries: incomeSummaries,
      cycleStartDate: cycleStartDate,
      cycleEndDate: cycleEndDate,
    );
  } catch (e, stack) {
    debugPrint('Error in dashboardProvider: $e');
    debugPrint(stack.toString());
    // Return empty state with current cycle dates to avoid UI crash
    final now = DateTime.now();
    return DashboardState(
      cycleStartDate: DateTime(now.year, now.month, 1),
      cycleEndDate: DateTime(now.year, now.month + 1, 1),
    );
  }
});

bool _isInDateRange(DateTime date, DashboardDateRange range) {
  return !date.isBefore(range.startDate) && date.isBefore(range.endDate);
}

double? _calculateChangePercentage(double current, double previous) {
  if (previous == 0) {
    return current == 0 ? 0 : null;
  }

  return ((current - previous) / previous.abs()) * 100;
}

DashboardDateRange _dateRangeFor(DashboardPeriod period, DateTime anchorDate) {
  switch (period) {
    case DashboardPeriod.monthly:
      return _monthlyCycleFor(anchorDate);
    case DashboardPeriod.quarterly:
      final quarterStartMonth = ((anchorDate.month - 1) ~/ 3) * 3 + 1;
      return DashboardDateRange(
        startDate: DateTime(anchorDate.year, quarterStartMonth, 1),
        endDate: DateTime(anchorDate.year, quarterStartMonth + 3, 1),
      );
    case DashboardPeriod.yearly:
      return DashboardDateRange(
        startDate: DateTime(anchorDate.year, 1, 1),
        endDate: DateTime(anchorDate.year + 1, 1, 1),
      );
  }
}

DashboardDateRange _previousDateRangeFor(
  DashboardPeriod period,
  DashboardDateRange currentRange,
) {
  switch (period) {
    case DashboardPeriod.monthly:
      return DashboardDateRange(
        startDate: DateTime(
          currentRange.startDate.year,
          currentRange.startDate.month - 1,
          currentRange.startDate.day,
        ),
        endDate: currentRange.startDate,
      );
    case DashboardPeriod.quarterly:
      return DashboardDateRange(
        startDate: DateTime(
          currentRange.startDate.year,
          currentRange.startDate.month - 3,
          1,
        ),
        endDate: currentRange.startDate,
      );
    case DashboardPeriod.yearly:
      return DashboardDateRange(
        startDate: DateTime(currentRange.startDate.year - 1, 1, 1),
        endDate: currentRange.startDate,
      );
  }
}

DashboardDateRange _monthlyCycleFor(DateTime anchorDate) {
  final cycleStartThisMonth = DateTime(
    anchorDate.year,
    anchorDate.month,
    AppConstants.startDayOfMonth,
  );

  if (!anchorDate.isBefore(cycleStartThisMonth)) {
    return DashboardDateRange(
      startDate: cycleStartThisMonth,
      endDate: DateTime(
        anchorDate.year,
        anchorDate.month + 1,
        AppConstants.startDayOfMonth,
      ),
    );
  }

  return DashboardDateRange(
    startDate: DateTime(
      anchorDate.year,
      anchorDate.month - 1,
      AppConstants.startDayOfMonth,
    ),
    endDate: cycleStartThisMonth,
  );
}
