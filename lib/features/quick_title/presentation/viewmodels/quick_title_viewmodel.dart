import 'package:kept_aom/features/quick_title/data/repositories/quick_title_repository_impl.dart';
import 'package:kept_aom/features/quick_title/domain/entities/quick_title_entity.dart';
import 'package:kept_aom/features/quick_title/domain/repositories/quick_title_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'quick_title_viewmodel.g.dart';

@riverpod
class QuickTitleViewModel extends _$QuickTitleViewModel {
  @override
  FutureOr<List<QuickTitleEntity>> build() {
    return ref.watch(quickTitleRepositoryProvider).fetchQuickTitles();
  }

  Future<void> fetchQuickTitles() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await ref.read(quickTitleRepositoryProvider).fetchQuickTitles();
    });
  }

  Future<void> addQuickTitle(QuickTitleEntity quicktitle) async {
    final repository = ref.read(quickTitleRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentList = state.value ?? [];
      final nextOrder = currentList.isEmpty
          ? 0
          : currentList
                  .map((e) => e.displayOrder ?? 0)
                  .reduce((a, b) => a > b ? a : b) +
              1;

      final newQuickTitle = QuickTitleEntity(
        id: quicktitle.id,
        icon: quicktitle.icon,
        userId: quicktitle.userId,
        typeId: quicktitle.typeId,
        title: quicktitle.title,
        categoryId: quicktitle.categoryId,
        displayOrder: nextOrder,
      );

      final added = await repository.addQuickTitle(newQuickTitle);
      if (added != null) {
        return [...currentList, added];
      }
      return currentList;
    });
  }

  Future<void> updateQuickTitle(QuickTitleEntity quicktitle) async {
    final repository = ref.read(quickTitleRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updated = await repository.updateQuickTitle(quicktitle);
      final currentList = state.value ?? [];
      if (updated != null) {
        return currentList.map((q) => q.id == updated.id ? updated : q).toList();
      }
      return currentList;
    });
  }

  Future<void> updateQuickTitlesOrder(List<QuickTitleEntity> titles) async {
    final repository = ref.read(quickTitleRepositoryProvider);
    final previousState = state;
    state = AsyncValue.data(titles);
    try {
      await repository.updateQuickTitlesOrder(titles);
    } catch (e, st) {
      state = previousState;
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteQuickTitle(QuickTitleEntity quicktitle) async {
    final repository = ref.read(quickTitleRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.deleteQuickTitle(quicktitle);
      final currentList = state.value ?? [];
      return currentList.where((q) => q.id != quicktitle.id).toList();
    });
  }
}
