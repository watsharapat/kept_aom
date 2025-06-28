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
      // ตรวจสอบข้อมูลที่จำเป็น (เช่น amount หรือ description)
      if (transaction.amount.isNaN) {
        throw Exception('Transaction amount must be double.');
      }
      if (transaction.title.length < 2) {
        throw Exception('Transaction title text cannot be empty.');
      }

      // หากข้อมูลผ่านการตรวจสอบแล้ว ดำเนินการส่งข้อมูล
      final response = await _supabase
          .from('transactions')
          .insert(transaction.toJson())
          .single();

      final insertedTransaction = Transaction.fromJson(response);

      _transactions.insert(0, insertedTransaction);
      notifyListeners();
    } catch (error) {
      print('Error adding transaction: $error');
      // เพิ่มการแจ้งเตือนผู้ใช้ (UI notification) ในกรณีที่เกิดข้อผิดพลาด
    }
  }

  Future<void> deleteTransaction(Transaction transaction) async {
    try {
      await _supabase
          .from('transactions')
          .delete()
          .eq('user_id', transaction.userId)
          .eq('date', transaction.date.toIso8601String())
          .eq('amount', transaction.amount)
          .eq('via', transaction.via)
          .eq('type_id', transaction.typeId)
          .eq('title', transaction.title)
          .eq('description', transaction.description);
      await fetchTransactions();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
    }
  }

  Future<void> updateTransaction(
      Transaction original, Transaction updated) async {
    try {
      await _supabase
          .from('transactions')
          .update(updated.toJson())
          .eq('user_id', original.userId)
          .eq('date', original.date.toIso8601String())
          .eq('amount', original.amount)
          .eq('via', original.via)
          .eq('type_id', original.typeId)
          .eq('title', original.title)
          .eq('description', original.description);
      await fetchTransactions();
    } catch (e) {
      debugPrint('Error updating transaction: $e');
    }
  }
}
