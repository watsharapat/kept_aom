import 'package:kept_aom/core/network/supabase_provider.dart';
import 'package:kept_aom/features/transaction/data/models/transaction_model.dart';
import 'package:kept_aom/features/transaction/domain/entities/transaction_entity.dart';
import 'package:kept_aom/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'transaction_repository_impl.g.dart';

class TransactionRemoteDatasource {
  final SupabaseClient _supabase;

  TransactionRemoteDatasource(this._supabase);

  Future<List<TransactionModel>> fetchTransactions() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('No user logged in');
    }

    final response = await _supabase
        .from('transactions')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false);

    return (response as List).map((e) => TransactionModel.fromJson(e)).toList();
  }

  Future<TransactionModel?> addTransaction(TransactionModel transaction) async {
    final response = await _supabase
        .from('transactions')
        .insert(transaction.toJson())
        .select()
        .single();

    return TransactionModel.fromJson(response);
  }

  Future<TransactionModel?> updateTransaction(TransactionModel transaction) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('No user logged in');

    final response = await _supabase
        .from('transactions')
        .update(transaction.toJson())
        .eq('user_id', userId)
        .eq('id', transaction.id!)
        .select()
        .single();

    return TransactionModel.fromJson(response);
  }

  Future<void> deleteTransaction(TransactionModel transaction) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('No user logged in');

    await _supabase
        .from('transactions')
        .delete()
        .eq('user_id', userId)
        .eq('id', transaction.id!);
  }
}

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDatasource _remoteDatasource;

  TransactionRepositoryImpl(this._remoteDatasource);

  @override
  Future<List<TransactionEntity>> fetchTransactions() {
    return _remoteDatasource.fetchTransactions();
  }

  @override
  Future<TransactionEntity?> addTransaction(TransactionEntity transaction) {
    return _remoteDatasource.addTransaction(TransactionModel.fromEntity(transaction));
  }

  @override
  Future<TransactionEntity?> updateTransaction(TransactionEntity transaction) {
    return _remoteDatasource.updateTransaction(TransactionModel.fromEntity(transaction));
  }

  @override
  Future<void> deleteTransaction(TransactionEntity transaction) {
    return _remoteDatasource.deleteTransaction(TransactionModel.fromEntity(transaction));
  }
}

@riverpod
TransactionRepository transactionRepository(TransactionRepositoryRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return TransactionRepositoryImpl(TransactionRemoteDatasource(supabase));
}
