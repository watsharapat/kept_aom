import 'package:kept_aom/core/network/supabase_provider.dart';
import 'package:kept_aom/features/saving_goal/data/models/saving_goal_model.dart';
import 'package:kept_aom/features/saving_goal/domain/entities/saving_goal_entity.dart';
import 'package:kept_aom/features/saving_goal/domain/repositories/saving_goal_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'saving_goal_repository_impl.g.dart';

class SavingGoalRemoteDatasource {
  final SupabaseClient _supabase;

  SavingGoalRemoteDatasource(this._supabase);

  Future<List<SavingGoalModel>> fetchSavingGoals() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('No user logged in');
    }

    final response = await _supabase
        .from('saving_goals')
        .select()
        .or('user_id.eq.$userId,user_id.is.null')
        .order('status_id', ascending: false);

    return (response as List).map((e) => SavingGoalModel.fromJson(e)).toList();
  }

  Future<SavingGoalModel?> addSavingGoal(SavingGoalModel savingGoal) async {
    final response = await _supabase
        .from('saving_goals')
        .insert(savingGoal.toJson())
        .select();
    if (response.isNotEmpty) {
      return SavingGoalModel.fromJson(response.first);
    }
    return null;
  }

  Future<SavingGoalModel?> updateSavingGoal(String oldName, SavingGoalModel savingGoal) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('No user logged in');

    final response = await _supabase
        .from('saving_goals')
        .update(savingGoal.toJson())
        .eq('user_id', userId)
        .eq('name', oldName)
        .select();

    if (response.isNotEmpty) {
      return SavingGoalModel.fromJson(response.first);
    }
    return null;
  }

  Future<void> deleteSavingGoal(String name) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('No user logged in');

    await _supabase
        .from('saving_goals')
        .delete()
        .eq('user_id', userId)
        .eq('name', name);
  }
}

class SavingGoalRepositoryImpl implements SavingGoalRepository {
  final SavingGoalRemoteDatasource _remoteDatasource;

  SavingGoalRepositoryImpl(this._remoteDatasource);

  @override
  Future<List<SavingGoalEntity>> fetchSavingGoals() {
    return _remoteDatasource.fetchSavingGoals();
  }

  @override
  Future<SavingGoalEntity?> addSavingGoal(SavingGoalEntity savingGoal) {
    return _remoteDatasource.addSavingGoal(SavingGoalModel.fromEntity(savingGoal));
  }

  @override
  Future<SavingGoalEntity?> updateSavingGoal(String oldName, SavingGoalEntity savingGoal) {
    return _remoteDatasource.updateSavingGoal(oldName, SavingGoalModel.fromEntity(savingGoal));
  }

  @override
  Future<void> deleteSavingGoal(String name) {
    return _remoteDatasource.deleteSavingGoal(name);
  }
}

@riverpod
SavingGoalRepository savingGoalRepository(SavingGoalRepositoryRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SavingGoalRepositoryImpl(SavingGoalRemoteDatasource(supabase));
}
