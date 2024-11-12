import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept_aom/models/transaction_model.dart';
import 'package:kept_aom/services/supabase_provider.dart';
import 'package:supabase/supabase.dart';

final homeProvider = ChangeNotifierProvider(
    (ref) => HomeProvider(ref.read(supabaseClientProvider)));

class HomeProvider extends ChangeNotifier {
  final SupabaseClient _supabase;

  HomeProvider(this._supabase) {
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
      final response = await _supabase
          .from('transactions')
          .insert(transaction.toJson())
          .single();
      final insertedTransaction =
          Transaction.fromJson(response as Map<String, dynamic>);

      _transactions.insert(0, insertedTransaction);
      notifyListeners();
    } catch (error) {
      print('Error adding transaction: $error');
      // You may want to add a UI notification for the user here
    }
  }
}
