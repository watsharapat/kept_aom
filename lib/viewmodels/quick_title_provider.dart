import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept_aom/models/quick_title_model.dart';
import 'package:kept_aom/services/supabase_provider.dart';
import 'package:supabase/supabase.dart';

final quickTitlesProvider = ChangeNotifierProvider(
    (ref) => QuickTitlesProvider(ref.read(supabaseClientProvider)));

class QuickTitlesProvider extends ChangeNotifier {
  final SupabaseClient _supabase;

  QuickTitlesProvider(this._supabase) {
    fetchQuickTitles();
  }

  List<QuickTitle> _quickTitles = [];
  // bool _isLoading = true;

  List<QuickTitle> get quickTitle => _quickTitles;
  // bool get isLoading => _isLoading;

  Future<void> fetchQuickTitles() async {
    try {
      // _isLoading = true;
      // notifyListeners();
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('No user logged in');
        return;
      }

      final response = await _supabase
          .from('quick_titles')
          .select()
          .or('user_id.eq.$userId,user_id.is.null')
          .order('type_id', ascending: false);

      print('Response: $response');
      _quickTitles = response.map((e) => QuickTitle.fromJson(e)).toList();
      print('Fetched quick titles: $_quickTitles');
    } catch (e) {
      print('Unexpected error: $e');
    } finally {
      // _isLoading = false;
      notifyListeners(); // Notify when loading is finished
    }
  }
}
