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
          .from('quick_title')
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

  Future<void> addQuickTitle(QuickTitle quicktitle) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('No user logged in');
        return;
      }

      // Insert the new quick title into the database
      final response = await _supabase
          .from('quick_title')
          .insert(quicktitle.toJsonWithoutId())
          .select();

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

  Future<void> updateQuickTitle(QuickTitle quicktitle) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('No user logged in');
        return;
      }

      // Update the quick title in the database
      final response = await _supabase
          .from('quick_title')
          .update(quicktitle.toJsonWithoutId())
          .eq('id', quicktitle.id!)
          .eq('user_id', userId)
          .select();

      if (response.isNotEmpty) {
        // Update the local list
        final updatedQuickTitle = QuickTitle.fromJson(response.first);
        final index = _quickTitles
            .indexWhere((qt) => qt.userId == userId && qt.id == quicktitle.id);
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

  Future<void> deleteQuickTitle(QuickTitle quicktitle) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('No user logged in');
        return;
      }

      await _supabase
          .from('quick_title')
          .delete()
          .eq('user_id', userId)
          .eq('id', quicktitle.id!);

      // Remove the quick title from the local list
      _quickTitles
          .removeWhere((qt) => qt.userId == userId && qt.id == quicktitle.id);
      notifyListeners(); // Notify listeners about the change
    } catch (e) {
      debugPrint('Error deleting quick title: $e');
    }
  }
}
