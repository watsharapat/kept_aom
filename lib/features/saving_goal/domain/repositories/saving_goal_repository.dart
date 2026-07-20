import 'package:kept_aom/features/saving_goal/domain/entities/saving_goal_entity.dart';

abstract class SavingGoalRepository {
  Future<List<SavingGoalEntity>> fetchSavingGoals();
  Future<SavingGoalEntity?> addSavingGoal(SavingGoalEntity savingGoal);
  Future<SavingGoalEntity?> updateSavingGoal(String oldName, SavingGoalEntity savingGoal);
  Future<void> deleteSavingGoal(String name);
}
