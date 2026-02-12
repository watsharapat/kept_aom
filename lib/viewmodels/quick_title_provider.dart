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
          .order('display_order', ascending: true);

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

      // Set display order to max + 1
      final nextOrder = _quickTitles.isEmpty
          ? 0
          : _quickTitles
                  .map((e) => e.displayOrder ?? 0)
                  .reduce((a, b) => a > b ? a : b) +
              1;

      final titleData = quicktitle.toJson();
      titleData['display_order'] = nextOrder;

      // Insert the new quick title into the database
      final response =
          await _supabase.from('quick_title').insert(titleData).select();

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
          .update(quicktitle.toJson())
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

  Future<void> updateQuickTitlesOrder(List<QuickTitle> titles) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Update local state first for responsiveness
      _quickTitles = titles;
      notifyListeners();

      // Perform batch update in Supabase
      // Note: Supabase doesn't have a direct "batch update different rows with different values" in a single call easily without RPC
      // but we can loop or use a single upsert if we have IDs.
      final updates = titles.asMap().entries.map((entry) {
        final index = entry.key;
        final title = entry.value;
        return {
          'id': title.id,
          'display_order': index,
          'user_id': title.userId ??
              userId, // Keep original user_id or current if null
          'icon': title.icon,
          'title': title.title,
          'type_id': title.typeId,
          'category_id': title.categoryId,
        };
      }).toList();

      await _supabase.from('quick_title').upsert(updates);
      debugPrint('Updated quick titles order in Supabase');
    } catch (e) {
      debugPrint('Error updating quick titles order: $e');
      // If it fails, we might want to refetch to sync back
      fetchQuickTitles();
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
