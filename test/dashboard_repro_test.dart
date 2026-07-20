import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept_aom/features/dashboard/presentation/viewmodels/dashboard_provider.dart';
import 'package:kept_aom/features/transaction/domain/entities/transaction_entity.dart';
import 'package:kept_aom/features/transaction/presentation/viewmodels/transaction_viewmodel.dart';
import 'dart:async';

// Mock TransactionViewModel
class MockTransactionViewModel extends TransactionViewModel {
  final List<TransactionEntity> _mockTransactions;
  MockTransactionViewModel(this._mockTransactions);

  @override
  FutureOr<List<TransactionEntity>> build() {
    return _mockTransactions;
  }

  @override
  Future<void> fetchTransactions() async {
    // No-op for test
  }
}

void main() {
  test('Dashboard Provider Logic Test', () {
    // Create dummy transactions
    final t1 = TransactionEntity(
      id: 1,
      userId: 'user1',
      date: DateTime.now(), // Today
      amount: 150.0,
      paymentType: 1,
      typeId: 2, // Income
      icon: '',
      title: 'Salary',
      categoryId: 1,
      description: '',
    );
    final t2 = TransactionEntity(
      id: 2,
      userId: 'user1',
      date: DateTime.now(), // Today
      amount: 50.0,
      paymentType: 1,
      typeId: 1, // Expense
      icon: '',
      title: 'Coffee',
      categoryId: 2,
      description: '',
    );

    final container = ProviderContainer(
      overrides: [
        transactionViewModelProvider.overrideWith(() => MockTransactionViewModel([t1, t2])),
      ],
    );

    // Read dashboard
    try {
      final dashboardState = container.read(dashboardProvider);
      expect(dashboardState.totalIncome, 150.0);
      expect(dashboardState.totalExpense, 50.0);
      expect(dashboardState.totalBalance, 100.0);
    } catch (e) {
      fail('Caught error: $e');
    }
  });
}
