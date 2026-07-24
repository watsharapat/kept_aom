import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kept_aom/features/transaction/presentation/viewmodels/transaction_viewmodel.dart';
import 'package:kept_aom/utils/constants.dart';

part 'dashboard_provider.g.dart';

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

class MonthlyCategorySpend {
  final DateTime cycleStartDate;
  final DateTime cycleEndDate;
  final String monthLabel;
  final Map<int, double> categoryTotals;
  final double totalAmount;

  MonthlyCategorySpend({
    required this.cycleStartDate,
    required this.cycleEndDate,
    required this.monthLabel,
    required this.categoryTotals,
    required this.totalAmount,
  });
}

class SixMonthCategoryComparisonData {
  final List<MonthlyCategorySpend> monthlyData;
  final List<int> topCategoryIds;
  final Map<int, double> categoryTotal6Months;
  final double overallTotal6Months;

  SixMonthCategoryComparisonData({
    required this.monthlyData,
    required this.topCategoryIds,
    required this.categoryTotal6Months,
    required this.overallTotal6Months,
  });
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

@riverpod
class DashboardPeriodState extends _$DashboardPeriodState {
  @override
  DashboardPeriod build() {
    return DashboardPeriod.monthly;
  }

  void setPeriod(DashboardPeriod period) {
    state = period;
  }
}

@riverpod
class DashboardAnchorDateState extends _$DashboardAnchorDateState {
  @override
  DateTime build() {
    return DateTime.now();
  }

  void setAnchorDate(DateTime date) {
    state = date;
  }
}

@riverpod
DashboardState dashboard(DashboardRef ref) {
  try {
    final transactionsAsync = ref.watch(transactionViewModelProvider);
    final transactions = transactionsAsync.value ?? [];
    final period = ref.watch(dashboardPeriodStateProvider);
    final anchorDate = ref.watch(dashboardAnchorDateStateProvider);

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
    final now = DateTime.now();
    return DashboardState(
      cycleStartDate: DateTime(now.year, now.month, 1),
      cycleEndDate: DateTime(now.year, now.month + 1, 1),
    );
  }
}

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

@riverpod
SixMonthCategoryComparisonData sixMonthCategoryComparison(
  SixMonthCategoryComparisonRef ref,
  bool isExpense,
) {
  final transactionsAsync = ref.watch(transactionViewModelProvider);
  final transactions = transactionsAsync.value ?? [];
  final anchorDate = ref.watch(dashboardAnchorDateStateProvider);

  final cycles = _getPast6MonthlyCycles(anchorDate);
  final targetTypeId = isExpense ? 1 : 2;

  const thaiShortMonths = [
    'ม.ค.',
    'ก.พ.',
    'มี.ค.',
    'เม.ย.',
    'พ.ค.',
    'มิ.ย.',
    'ก.ค.',
    'ส.ค.',
    'ก.ย.',
    'ต.ค.',
    'พ.ย.',
    'ธ.ค.',
  ];

  final List<MonthlyCategorySpend> monthlyData = [];
  final Map<int, double> categoryTotal6Months = {};
  double overallTotal6Months = 0.0;

  for (final cycle in cycles) {
    final sampleDate = cycle.endDate.subtract(const Duration(days: 10));
    final monthLabel = thaiShortMonths[sampleDate.month - 1];

    final Map<int, double> catTotals = {};
    double monthTotal = 0.0;

    for (final transaction in transactions) {
      if (transaction.typeId != targetTypeId) continue;
      final date = transaction.date;
      if (!date.isBefore(cycle.startDate) && date.isBefore(cycle.endDate)) {
        final amt = transaction.amount.abs();
        catTotals[transaction.categoryId] =
            (catTotals[transaction.categoryId] ?? 0.0) + amt;
        monthTotal += amt;

        categoryTotal6Months[transaction.categoryId] =
            (categoryTotal6Months[transaction.categoryId] ?? 0.0) + amt;
        overallTotal6Months += amt;
      }
    }

    monthlyData.add(
      MonthlyCategorySpend(
        cycleStartDate: cycle.startDate,
        cycleEndDate: cycle.endDate,
        monthLabel: monthLabel,
        categoryTotals: catTotals,
        totalAmount: monthTotal,
      ),
    );
  }

  final sortedCategories = categoryTotal6Months.keys.toList()
    ..sort(
      (a, b) =>
          (categoryTotal6Months[b] ?? 0).compareTo(categoryTotal6Months[a] ?? 0),
    );

  return SixMonthCategoryComparisonData(
    monthlyData: monthlyData,
    topCategoryIds: sortedCategories,
    categoryTotal6Months: categoryTotal6Months,
    overallTotal6Months: overallTotal6Months,
  );
}

List<DashboardDateRange> _getPast6MonthlyCycles(DateTime anchorDate) {
  final List<DashboardDateRange> cycles = [];
  DashboardDateRange current = _monthlyCycleFor(anchorDate);
  cycles.add(current);

  for (int i = 0; i < 5; i++) {
    final prevDate = current.startDate.subtract(const Duration(days: 10));
    current = _monthlyCycleFor(prevDate);
    cycles.add(current);
  }

  return cycles.reversed.toList();
}

