import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kept_aom/features/category/data/models/category_model.dart';

class CategoryRemoteDatasource {
  final SupabaseClient _supabase;

  CategoryRemoteDatasource(this._supabase);

  Future<List<CategoryModel>> fetchCategories() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('No user logged in');
    }
    final response = await _supabase
        .from('transaction_category')
        .select()
        .or('user_id.eq.$userId,user_id.is.null')
        .order('id', ascending: true);

    return (response as List).map((e) => CategoryModel.fromJson(e)).toList();
  }

  Future<CategoryModel> addCategory(CategoryModel category) async {
    final categoryData = category.toJson();
    if (category.categoryId == 0) {
      categoryData.remove('id');
    }
    final response = await _supabase
        .from('transaction_category')
        .insert(categoryData)
        .select();
    
    if (response.isEmpty) {
      throw Exception('Failed to add category');
    }
    return CategoryModel.fromJson(response.first);
  }

  Future<CategoryModel> updateCategory(CategoryModel category) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('No user logged in');
    }
    final response = await _supabase
        .from('transaction_category')
        .update(category.toJson())
        .eq('id', category.categoryId)
        .eq('user_id', userId)
        .select();

    if (response.isEmpty) {
      throw Exception('Failed to update category');
    }
    return CategoryModel.fromJson(response.first);
  }

  Future<void> deleteCategory(CategoryModel category) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('No user logged in');
    }
    await _supabase
        .from('transaction_category')
        .delete()
        .eq('user_id', userId)
        .eq('id', category.categoryId);
  }
}
