import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept_aom/viewmodels/dashboard_provider.dart';
import 'package:kept_aom/models/transaction_model.dart';
import 'package:kept_aom/viewmodels/transaction_provider.dart';
import 'package:kept_aom/utils/constants.dart';

import 'package:supabase/supabase.dart';

// Mock SupabaseClient
class MockSupabaseClient extends Fake implements SupabaseClient {}

// Mock TransactionProvider
class MockTransactionProvider extends TransactionProvider {
  MockTransactionProvider()
      : super(MockSupabaseClient()); // Avoid using null

  @override
  Future<void> fetchTransactions() async {
    // Override to prevent using the null supabase client
  }

  @override
  List<Transaction> get transactions => _mockTransactions;

  List<Transaction> _mockTransactions = [];
  set mockTransactions(List<Transaction> val) => _mockTransactions = val;
}

void main() {
  test('Dashboard Provider Logic Test', () {
    final container = ProviderContainer(
      overrides: [
        transactionProvider.overrideWith((ref) => MockTransactionProvider()),
      ],
    );

    // Create dummy transactions
    final t1 = Transaction(
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
    final t2 = Transaction(
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

    // Inject into mock
    final mock =
        container.read(transactionProvider.notifier) as MockTransactionProvider;
    mock.mockTransactions = [t1, t2];

    // Read dashboard
    try {
      final dashboardState = container.read(dashboardProvider);
      expect(dashboardState.totalIncome, 150.0);
      expect(dashboardState.totalExpense, 50.0);
      expect(dashboardState.totalBalance, 100.0);
      print('Balance: ${dashboardState.totalBalance}');
      print('Income: ${dashboardState.totalIncome}');
      print('Expense: ${dashboardState.totalExpense}');
      print('Cycle Start: ${dashboardState.cycleStartDate}');
    } catch (e) {
      print('Caught error: $e');
      rethrow;
    }
  });
}
