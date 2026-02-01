import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept_aom/viewmodels/dashboard_provider.dart';
import 'package:kept_aom/models/transaction_model.dart';
import 'package:kept_aom/viewmodels/transaction_provider.dart';
import 'package:kept_aom/utils/constants.dart';

// Mock TransactionProvider
class MockTransactionProvider extends TransactionProvider {
  MockTransactionProvider()
      : super(null as dynamic); // Hack to avoid Supabase dep

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

    // Create a dummy transaction
    final t1 = Transaction(
      id: 1,
      userId: 'user1',
      date: DateTime.now(), // Today
      amount: 100.0,
      paymentType: 1,
      typeId: 2, // Income
      icon: '',
      title: 'Salary',
      categoryId: 1,
      description: '',
    );

    // Inject into mock
    final mock =
        container.read(transactionProvider.notifier) as MockTransactionProvider;
    mock.mockTransactions = [t1];

    // Read dashboard
    try {
      final dashboardState = container.read(dashboardProvider);
      print('Balance: ${dashboardState.totalBalance}');
      print('Cycle Start: ${dashboardState.cycleStartDate}');
    } catch (e) {
      print('Caught error: $e');
      rethrow;
    }
  });
}
