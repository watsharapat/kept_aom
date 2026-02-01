import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept_aom/models/transaction_category.dart';
import 'package:kept_aom/services/supabase_provider.dart';
import 'package:supabase/supabase.dart';

final categoryProvider = ChangeNotifierProvider(
    (ref) => CategoryProvider(ref.read(supabaseClientProvider)));

class CategoryProvider extends ChangeNotifier {
  final SupabaseClient _supabase;

  CategoryProvider(this._supabase) {
    fetchCategories();
  }

  List<TransactionCategory> _categories = [];

  List<TransactionCategory> get categories => _categories;

  Future<void> fetchCategories() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('No user logged in');
        return;
      }

      final response = await _supabase
          .from('transaction_category')
          .select()
          .or('user_id.eq.$userId,user_id.is.null')
          .order('id', ascending: true);

      debugPrint('Categories fetched: ${response.toString()}');
      _categories =
          response.map((e) => TransactionCategory.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  TransactionCategory? getCategoryById(int id) {
    try {
      return _categories.firstWhere((cat) => cat.categoryId == id);
    } catch (e) {
      return null;
    }
  }

  List<TransactionCategory> getCategoriesByType(int typeId) {
    return _categories.where((cat) => cat.typeId == typeId).toList();
  }
}
