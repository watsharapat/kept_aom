import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept_aom/models/quick_title_model.dart';
import 'package:kept_aom/models/saving_goals_model.dart';
import 'package:kept_aom/services/supabase_provider.dart';
import 'package:kept_aom/views/pages/saving_goals_page.dart';
import 'package:supabase/supabase.dart';

//IN PROGRESS

final savingGoalsProvider = ChangeNotifierProvider(
    (ref) => SavingGoalsProvider(ref.read(supabaseClientProvider)));

class SavingGoalsProvider extends ChangeNotifier {
  final SupabaseClient _supabase;

  SavingGoalsProvider(this._supabase) {
    fetchSavingGoals();
  }

  List<SavingGoals> _savingGoals = [];
  // bool _isLoading = true;

  List<SavingGoals> get savingGoals => _savingGoals;
  // bool get isLoading => _isLoading;

  Future<void> fetchSavingGoals() async {
    try {
      // _isLoading = true;
      // notifyListeners();
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('No user logged in');
        return;
      }

      final response = await _supabase
          .from('saving_goals')
          .select()
          .or('user_id.eq.$userId,user_id.is.null')
          .order('type_id', ascending: false);

      debugPrint('Response: $response');
      _savingGoals = response.map((e) => SavingGoals.fromJson(e)).toList();
      debugPrint('Fetched quick titles: $_savingGoals');
    } catch (e) {
      debugPrint('Unexpected error: $e');
    } finally {
      // _isLoading = false;
      notifyListeners(); // Notify when loading is finished
    }
  }

  Future<void> addSavingGoals(String emoji, String title, int typeId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('No user logged in');
        return;
      }

      String fullTitle = "$emoji $title";

      // Insert the new quick title into the database
      final response = await _supabase.from('saving_goals').insert({
        'title': fullTitle,
        'type_id': typeId,
        'user_id': userId,
      }).select();

      if (response.isNotEmpty) {
        // Add the new quick title to the local list
        final newSavingGoal = SavingGoals.fromJson(response.first);
        _savingGoals.add(newSavingGoal);
        notifyListeners(); // Notify listeners about the change
        debugPrint('Added new saviing goal: $newSavingGoal');
      }
    } catch (e) {
      debugPrint('Error adding saving goal: $e');
    }
  }

  Future<void> updateSavingGoals(
      String oldTitle, String newTitle, int typeId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('No user logged in');
        return;
      }

      // Update the quick title in the database
      final response = await _supabase
          .from('saving_goals')
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
        final updatedSavingGoal = SavingGoals.fromJson(response.first);
        final index = _savingGoals
            .indexWhere((sg) => sg.userId == userId && sg.name == oldTitle);
        if (index != -1) {
          _savingGoals[index] = updatedSavingGoal;
        }
        notifyListeners();
        debugPrint('Updated saving goals: $updatedSavingGoal');
      }
    } catch (e) {
      debugPrint('Error updating saving goals: $e');
    }
  }

  Future<void> deleteSavingGoals(String title) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('No user logged in');
        return;
      }

      // Delete the quick title from the database
      await _supabase
          .from('saving_goals')
          .delete()
          .eq('user_id', userId)
          .eq('name', title);

      // Remove the quick title from the local list
      _savingGoals.removeWhere((sv) => sv.userId == userId && sv.name == title);
      notifyListeners(); // Notify listeners about the change
    } catch (e) {
      debugPrint('Error deleting quick title: $e');
    }
  }
}
