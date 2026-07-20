import 'package:kept_aom/features/saving_goal/data/repositories/saving_goal_repository_impl.dart';
import 'package:kept_aom/features/saving_goal/domain/entities/saving_goal_entity.dart';
import 'package:kept_aom/features/saving_goal/domain/repositories/saving_goal_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'saving_goal_viewmodel.g.dart';

@riverpod
class SavingGoalViewModel extends _$SavingGoalViewModel {
  @override
  FutureOr<List<SavingGoalEntity>> build() {
    return ref.watch(savingGoalRepositoryProvider).fetchSavingGoals();
  }

  Future<void> fetchSavingGoals() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await ref.read(savingGoalRepositoryProvider).fetchSavingGoals();
    });
  }

  Future<void> addSavingGoal(SavingGoalEntity savingGoal) async {
    final repository = ref.read(savingGoalRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final added = await repository.addSavingGoal(savingGoal);
      final currentList = state.value ?? [];
      if (added != null) {
        return [...currentList, added];
      }
      return currentList;
    });
  }

  Future<void> updateSavingGoal(String oldName, SavingGoalEntity savingGoal) async {
    final repository = ref.read(savingGoalRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updated = await repository.updateSavingGoal(oldName, savingGoal);
      final currentList = state.value ?? [];
      if (updated != null) {
        return currentList.map((sg) => sg.name == oldName ? updated : sg).toList();
      }
      return currentList;
    });
  }

  Future<void> deleteSavingGoal(String name) async {
    final repository = ref.read(savingGoalRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.deleteSavingGoal(name);
      final currentList = state.value ?? [];
      return currentList.where((sg) => sg.name != name).toList();
    });
  }
}
