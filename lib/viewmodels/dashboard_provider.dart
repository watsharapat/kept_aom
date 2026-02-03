import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kept_aom/viewmodels/transaction_provider.dart';
import 'package:kept_aom/utils/constants.dart';

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

class DashboardState {
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final List<CategorySummary> expenseSummaries;
  final List<CategorySummary> incomeSummaries;
  final DateTime cycleStartDate;
  final DateTime cycleEndDate;

  DashboardState({
    this.totalBalance = 0.0,
    this.totalIncome = 0.0,
    this.totalExpense = 0.0,
    this.expenseSummaries = const [],
    this.incomeSummaries = const [],
    required this.cycleStartDate,
    required this.cycleEndDate,
  });
}

final dashboardProvider = Provider<DashboardState>((ref) {
  try {
    final transactionState = ref.watch(transactionProvider);
    final transactions = transactionState.transactions;

    // Calculate current billing cycle dates
    final now = DateTime.now();
    final DateTime cycleStartDate;
    final DateTime cycleEndDate;

    if (now.day >= AppConstants.startDayOfMonth) {
      cycleStartDate =
          DateTime(now.year, now.month, AppConstants.startDayOfMonth);
      cycleEndDate =
          DateTime(now.year, now.month + 1, AppConstants.startDayOfMonth);
    } else {
      cycleStartDate =
          DateTime(now.year, now.month - 1, AppConstants.startDayOfMonth);
      cycleEndDate =
          DateTime(now.year, now.month, AppConstants.startDayOfMonth);
    }

    double income = 0.0;
    double expense = 0.0;
    Map<int, double> expenseTotals = {};
    Map<int, int> expenseCounts = {};
    Map<int, double> incomeTotals = {};
    Map<int, int> incomeCounts = {};

    for (var transaction in transactions) {
      // Filter by date cycle
      final date = transaction.date;
      if (date.isBefore(cycleStartDate) ||
          date.isAfter(cycleEndDate.subtract(const Duration(seconds: 1)))) {
        continue;
      }

      // typeId 1 = Expense, 2 = Income
      if (transaction.typeId == 2) {
        income += transaction.amount;
        final currentTotal = incomeTotals[transaction.categoryId] ?? 0.0;
        incomeTotals[transaction.categoryId] =
            currentTotal + transaction.amount;

        final currentCount = incomeCounts[transaction.categoryId] ?? 0;
        incomeCounts[transaction.categoryId] = currentCount + 1;
      } else if (transaction.typeId == 1) {
        expense += transaction.amount;
        final currentTotal = expenseTotals[transaction.categoryId] ?? 0.0;
        expenseTotals[transaction.categoryId] =
            currentTotal + transaction.amount;

        final currentCount = expenseCounts[transaction.categoryId] ?? 0;
        expenseCounts[transaction.categoryId] = currentCount + 1;
      }
    }

    // Calculate summaries
    final List<CategorySummary> expenseSummaries = [];
    expenseTotals.forEach((categoryId, amount) {
      double percentage = 0.0;
      if (expense != 0) {
        percentage = (amount / expense) * 100;
      }
      expenseSummaries.add(CategorySummary(
        categoryId: categoryId,
        totalAmount: amount,
        percentage: percentage,
        transactionCount: expenseCounts[categoryId] ?? 0,
      ));
    });
    expenseSummaries
        .sort((a, b) => b.totalAmount.abs().compareTo(a.totalAmount.abs()));

    final List<CategorySummary> incomeSummaries = [];
    incomeTotals.forEach((categoryId, amount) {
      double percentage = 0.0;
      if (income != 0) {
        percentage = (amount / income) * 100;
      }
      incomeSummaries.add(CategorySummary(
        categoryId: categoryId,
        totalAmount: amount,
        percentage: percentage,
        transactionCount: incomeCounts[categoryId] ?? 0,
      ));
    });
    incomeSummaries
        .sort((a, b) => b.totalAmount.abs().compareTo(a.totalAmount.abs()));

    return DashboardState(
      totalBalance: income + expense,
      totalIncome: income,
      totalExpense: expense,
      expenseSummaries: expenseSummaries,
      incomeSummaries: incomeSummaries,
      cycleStartDate: cycleStartDate,
      cycleEndDate: cycleEndDate,
    );
  } catch (e, stack) {
    print('Error in dashboardProvider: $e');
    print(stack);
    // Return empty state with current cycle dates to avoid UI crash
    final now = DateTime.now();
    return DashboardState(
      cycleStartDate: DateTime(now.year, now.month, 1),
      cycleEndDate: DateTime(now.year, now.month + 1, 1),
    );
  }
});
