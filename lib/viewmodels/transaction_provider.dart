import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept_aom/models/transaction_model.dart';
import 'package:kept_aom/services/supabase_provider.dart';
import 'package:supabase/supabase.dart';

final transactionProvider = ChangeNotifierProvider(
    (ref) => TransactionProvider(ref.read(supabaseClientProvider)));

class TransactionProvider extends ChangeNotifier {
  final SupabaseClient _supabase;

  TransactionProvider(this._supabase) {
    fetchTransactions();
  }

  List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

  Future<void> fetchTransactions() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('No user logged in');
        return;
      }

      final response = await _supabase
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);

      debugPrint(response.toList().toString());
      _transactions = response.map((e) => Transaction.fromJson(e)).toList();
      notifyListeners(); // Ensure this is in a ChangeNotifier class
    } catch (e) {
      print('Unexpected error: $e');
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      // ตรวจสอบข้อมูลที่จำเป็น (เช่น amount)
      if (transaction.amount.isNaN) {
        throw Exception('Transaction amount must be a valid number.');
      }
      if (transaction.title.isEmpty) {
        throw Exception('Transaction title cannot be empty.');
      }

      // หากข้อมูลผ่านการตรวจสอบแล้ว ดำเนินการส่งข้อมูล
      final response = await _supabase
          .from('transactions')
          .insert(transaction.toJson())
          .select()
          .single();

      final insertedTransaction = Transaction.fromJson(response);

      _transactions.insert(0, insertedTransaction);
      notifyListeners();
    } catch (error) {
      debugPrint('Error adding transaction: $error');
      // Re-throw the error so the UI can catch it and show a message
      rethrow;
    }
  }

  Future<void> deleteTransaction(Transaction transaction) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('No user logged in');
        return;
      }
      await _supabase
          .from('transactions')
          .delete()
          .eq('user_id', userId)
          .eq('id', transaction.id!);
      await fetchTransactions();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
    }
  }

  Future<void> updateTransaction(Transaction updated) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('No user logged in');
        return;
      }
      await _supabase
          .from('transactions')
          .update(updated.toJson())
          .eq('user_id', userId)
          .eq('id', updated.id!);
      await fetchTransactions();
    } catch (e) {
      debugPrint('Error updating transaction: $e');
    }
  }
}
