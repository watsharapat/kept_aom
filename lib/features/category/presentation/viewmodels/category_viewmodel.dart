import 'package:kept_aom/features/category/data/repositories/category_repository_impl.dart';
import 'package:kept_aom/features/category/domain/entities/category_entity.dart';
import 'package:kept_aom/features/category/domain/repositories/category_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'category_viewmodel.g.dart';

@riverpod
class CategoryViewModel extends _$CategoryViewModel {
  @override
  FutureOr<List<CategoryEntity>> build() async {
    return ref.watch(categoryRepositoryProvider).fetchCategories();
  }

  Future<void> fetchCategories() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await ref.read(categoryRepositoryProvider).fetchCategories();
    });
  }

  Future<void> addCategory(CategoryEntity category) async {
    final repository = ref.read(categoryRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final newCategory = await repository.addCategory(category);
      final currentList = state.value ?? [];
      if (newCategory != null) {
        return [...currentList, newCategory];
      }
      return currentList;
    });
  }

  Future<void> updateCategory(CategoryEntity category) async {
    final repository = ref.read(categoryRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updated = await repository.updateCategory(category);
      final currentList = state.value ?? [];
      if (updated != null) {
        return currentList.map((c) => c.categoryId == updated.categoryId ? updated : c).toList();
      }
      return currentList;
    });
  }

  Future<void> deleteCategory(CategoryEntity category) async {
    final repository = ref.read(categoryRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.deleteCategory(category);
      final currentList = state.value ?? [];
      return currentList.where((c) => c.categoryId != category.categoryId).toList();
    });
  }
}

@riverpod
List<CategoryEntity> categoriesByType(CategoriesByTypeRef ref, int typeId) {
  final categoriesAsync = ref.watch(categoryViewModelProvider);
  return categoriesAsync.value?.where((cat) => cat.typeId == typeId).toList() ?? [];
}

@riverpod
CategoryEntity? categoryById(CategoryByIdRef ref, int id) {
  final categoriesAsync = ref.watch(categoryViewModelProvider);
  final list = categoriesAsync.value;
  if (list == null) return null;
  for (final cat in list) {
    if (cat.categoryId == id) return cat;
  }
  return null;
}
