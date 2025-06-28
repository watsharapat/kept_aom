import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept_aom/models/saving_goals_model.dart';
import 'package:kept_aom/services/supabase_provider.dart';
import 'package:supabase/supabase.dart';

final savingGoalsProvider = ChangeNotifierProvider(
    (ref) => SavingGoalsProvider(ref.read(supabaseClientProvider)));

class SavingGoalsProvider extends ChangeNotifier {
  final SupabaseClient _supabase;

  SavingGoalsProvider(this._supabase) {
    fetchSavingGoals();
  }

  List<SavingGoals> _savingGoals = [];

  List<SavingGoals> get savingGoals => _savingGoals;

  Future<void> fetchSavingGoals() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('No user logged in');
        return;
      }

      final response = await _supabase
          .from('saving_goals')
          .select()
          .or('user_id.eq.$userId,user_id.is.null')
          .order('status_id', ascending: false);

      debugPrint('Response: $response');
      _savingGoals = response.map((e) => SavingGoals.fromJson(e)).toList();
      debugPrint('Fetched saving goals: $_savingGoals');
    } catch (e) {
      debugPrint('Unexpected error: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> addSavingGoals({
    required String name,
    required int stored,
    required int target,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('No user logged in');
        return;
      }

      final response = await _supabase.from('saving_goals').insert({
        'name': name,
        'status_id': "0",
        'stored': stored,
        'target': target,
        'user_id': userId,
      }).select();

      if (response.isNotEmpty) {
        final newSavingGoal = SavingGoals.fromJson(response.first);
        _savingGoals.add(newSavingGoal);
        notifyListeners();
        debugPrint('Added new saving goal: $newSavingGoal');
      }
    } catch (e) {
      debugPrint('Error adding saving goal: $e');
    }
  }

  Future<void> updateSavingGoals({
    required String oldName,
    required String name,
    required int stored,
    required int target,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('No user logged in');
        return;
      }
      final statusId = stored >= target ? 1 : 0;

      final response = await _supabase
          .from('saving_goals')
          .update({
            'name': name,
            'status_id': statusId,
            'stored': stored,
            'target': target,
            'user_id': userId,
          })
          .eq('user_id', userId)
          .eq('name', oldName)
          .select();

      if (response.isNotEmpty) {
        final updatedSavingGoal = SavingGoals.fromJson(response.first);
        final index = _savingGoals
            .indexWhere((sg) => sg.userId == userId && sg.name == oldName);
        if (index != -1) {
          _savingGoals[index] = updatedSavingGoal;
        }
        notifyListeners();
        debugPrint('Updated saving goal: $updatedSavingGoal');
      }
    } catch (e) {
      debugPrint('Error updating saving goal: $e');
    }
  }

  Future<void> deleteSavingGoals(String name) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('No user logged in');
        return;
      }

      await _supabase
          .from('saving_goals')
          .delete()
          .eq('user_id', userId)
          .eq('name', name);

      _savingGoals.removeWhere((sv) => sv.userId == userId && sv.name == name);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting saving goal: $e');
    }
  }
}
