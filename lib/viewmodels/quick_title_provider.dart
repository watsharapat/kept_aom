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

      debugPrint('Response: $response');
      _quickTitles = response.map((e) => QuickTitle.fromJson(e)).toList();
      debugPrint('Fetched quick titles: $_quickTitles');
    } catch (e) {
      debugPrint('Unexpected error: $e');
    } finally {
      // _isLoading = false;
      notifyListeners(); // Notify when loading is finished
    }
  }

  Future<void> addQuickTitle(String emoji, String title, int typeId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('No user logged in');
        return;
      }

      String fullTitle = "$emoji $title";

      // Insert the new quick title into the database
      final response = await _supabase.from('quick_titles').insert({
        'title': fullTitle,
        'type_id': typeId,
        'user_id': userId,
      }).select();

      if (response.isNotEmpty) {
        // Add the new quick title to the local list
        final newQuickTitle = QuickTitle.fromJson(response.first);
        _quickTitles.add(newQuickTitle);
        notifyListeners(); // Notify listeners about the change
        debugPrint('Added new quick title: $newQuickTitle');
      }
    } catch (e) {
      debugPrint('Error adding quick title: $e');
    }
  }

  Future<void> updateQuickTitle(
      String oldTitle, String newTitle, int typeId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('No user logged in');
        return;
      }

      // Update the quick title in the database
      final response = await _supabase
          .from('quick_titles')
          .update({
            'title': newTitle,
            'type_id': typeId,
            'user_id': userId,
          })
          .eq('user_id', userId)
          .eq('title', oldTitle)
          .select();

      if (response.isNotEmpty) {
        // Update the local list
        final updatedQuickTitle = QuickTitle.fromJson(response.first);
        final index = _quickTitles
            .indexWhere((qt) => qt.userId == userId && qt.title == oldTitle);
        if (index != -1) {
          _quickTitles[index] = updatedQuickTitle;
        }
        notifyListeners();
        debugPrint('Updated quick title: $updatedQuickTitle');
      }
    } catch (e) {
      debugPrint('Error updating quick title: $e');
    }
  }

  Future<void> deleteQuickTitle(String title) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('No user logged in');
        return;
      }

      // Delete the quick title from the database
      await _supabase
          .from('quick_titles')
          .delete()
          .eq('user_id', userId)
          .eq('title', title);

      // Remove the quick title from the local list
      _quickTitles
          .removeWhere((qt) => qt.userId == userId && qt.title == title);
      notifyListeners(); // Notify listeners about the change
    } catch (e) {
      debugPrint('Error deleting quick title: $e');
    }
  }
}
