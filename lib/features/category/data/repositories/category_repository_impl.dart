import 'package:kept_aom/core/network/supabase_provider.dart';
import 'package:kept_aom/features/category/data/datasources/category_remote_datasource.dart';
import 'package:kept_aom/features/category/data/models/category_model.dart';
import 'package:kept_aom/features/category/domain/entities/category_entity.dart';
import 'package:kept_aom/features/category/domain/repositories/category_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'category_repository_impl.g.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDatasource _remoteDatasource;

  CategoryRepositoryImpl(this._remoteDatasource);

  @override
  Future<List<CategoryEntity>> fetchCategories() {
    return _remoteDatasource.fetchCategories();
  }

  @override
  Future<CategoryEntity?> addCategory(CategoryEntity category) {
    return _remoteDatasource.addCategory(CategoryModel.fromEntity(category));
  }

  @override
  Future<CategoryEntity?> updateCategory(CategoryEntity category) {
    return _remoteDatasource.updateCategory(CategoryModel.fromEntity(category));
  }

  @override
  Future<void> deleteCategory(CategoryEntity category) {
    return _remoteDatasource.deleteCategory(CategoryModel.fromEntity(category));
  }
}

@riverpod
CategoryRepository categoryRepository(CategoryRepositoryRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return CategoryRepositoryImpl(CategoryRemoteDatasource(supabase));
}
