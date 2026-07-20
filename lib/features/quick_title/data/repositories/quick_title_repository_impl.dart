import 'package:kept_aom/core/network/supabase_provider.dart';
import 'package:kept_aom/features/quick_title/data/models/quick_title_model.dart';
import 'package:kept_aom/features/quick_title/domain/entities/quick_title_entity.dart';
import 'package:kept_aom/features/quick_title/domain/repositories/quick_title_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'quick_title_repository_impl.g.dart';

class QuickTitleRemoteDatasource {
  final SupabaseClient _supabase;

  QuickTitleRemoteDatasource(this._supabase);

  Future<List<QuickTitleModel>> fetchQuickTitles() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('No user logged in');
    }

    final response = await _supabase
        .from('quick_title')
        .select()
        .or('user_id.eq.$userId,user_id.is.null')
        .order('display_order', ascending: true);

    return (response as List).map((e) => QuickTitleModel.fromJson(e)).toList();
  }

  Future<QuickTitleModel?> addQuickTitle(QuickTitleModel quicktitle) async {
    final response = await _supabase
        .from('quick_title')
        .insert(quicktitle.toJson())
        .select();
    if (response.isNotEmpty) {
      return QuickTitleModel.fromJson(response.first);
    }
    return null;
  }

  Future<QuickTitleModel?> updateQuickTitle(QuickTitleModel quicktitle) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('No user logged in');

    final response = await _supabase
        .from('quick_title')
        .update(quicktitle.toJson())
        .eq('id', quicktitle.id!)
        .eq('user_id', userId)
        .select();

    if (response.isNotEmpty) {
      return QuickTitleModel.fromJson(response.first);
    }
    return null;
  }

  Future<void> updateQuickTitleOrder(int id, int order) async {
    await _supabase
        .from('quick_title')
        .update({'display_order': order})
        .eq('id', id);
  }

  Future<void> deleteQuickTitle(QuickTitleModel quicktitle) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('No user logged in');

    await _supabase
        .from('quick_title')
        .delete()
        .eq('user_id', userId)
        .eq('id', quicktitle.id!);
  }
}

class QuickTitleRepositoryImpl implements QuickTitleRepository {
  final QuickTitleRemoteDatasource _remoteDatasource;

  QuickTitleRepositoryImpl(this._remoteDatasource);

  @override
  Future<List<QuickTitleEntity>> fetchQuickTitles() {
    return _remoteDatasource.fetchQuickTitles();
  }

  @override
  Future<QuickTitleEntity?> addQuickTitle(QuickTitleEntity quicktitle) {
    return _remoteDatasource.addQuickTitle(QuickTitleModel.fromEntity(quicktitle));
  }

  @override
  Future<QuickTitleEntity?> updateQuickTitle(QuickTitleEntity quicktitle) {
    return _remoteDatasource.updateQuickTitle(QuickTitleModel.fromEntity(quicktitle));
  }

  @override
  Future<void> updateQuickTitlesOrder(List<QuickTitleEntity> titles) async {
    for (var i = 0; i < titles.length; i++) {
      final title = titles[i];
      if (title.id != null) {
        await _remoteDatasource.updateQuickTitleOrder(title.id!, i);
      }
    }
  }

  @override
  Future<void> deleteQuickTitle(QuickTitleEntity quicktitle) {
    return _remoteDatasource.deleteQuickTitle(QuickTitleModel.fromEntity(quicktitle));
  }
}

@riverpod
QuickTitleRepository quickTitleRepository(QuickTitleRepositoryRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return QuickTitleRepositoryImpl(QuickTitleRemoteDatasource(supabase));
}
