import 'package:kept_aom/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:kept_aom/features/transaction/domain/entities/transaction_entity.dart';
import 'package:kept_aom/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_viewmodel.g.dart';

@riverpod
class TransactionViewModel extends _$TransactionViewModel {
  @override
  FutureOr<List<TransactionEntity>> build() {
    return ref.watch(transactionRepositoryProvider).fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await ref.read(transactionRepositoryProvider).fetchTransactions();
    });
  }

  Future<void> addTransaction(TransactionEntity transaction) async {
    final repository = ref.read(transactionRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (transaction.amount.isNaN) {
        throw Exception('Transaction amount must be a valid number.');
      }
      if (transaction.title.isEmpty) {
        throw Exception('Transaction title cannot be empty.');
      }

      final added = await repository.addTransaction(transaction);
      final currentList = state.value ?? [];
      if (added != null) {
        return [added, ...currentList];
      }
      return currentList;
    });
  }

  Future<void> updateTransaction(TransactionEntity transaction) async {
    final repository = ref.read(transactionRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updated = await repository.updateTransaction(transaction);
      final currentList = state.value ?? [];
      if (updated != null) {
        return currentList.map((t) => t.id == updated.id ? updated : t).toList();
      }
      return currentList;
    });
  }

  Future<void> deleteTransaction(TransactionEntity transaction) async {
    final repository = ref.read(transactionRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.deleteTransaction(transaction);
      final currentList = state.value ?? [];
      return currentList.where((t) => t.id != transaction.id).toList();
    });
  }
}
