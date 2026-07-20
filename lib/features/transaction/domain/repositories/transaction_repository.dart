import 'package:kept_aom/features/transaction/domain/entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<List<TransactionEntity>> fetchTransactions();
  Future<TransactionEntity?> addTransaction(TransactionEntity transaction);
  Future<TransactionEntity?> updateTransaction(TransactionEntity transaction);
  Future<void> deleteTransaction(TransactionEntity transaction);
}
