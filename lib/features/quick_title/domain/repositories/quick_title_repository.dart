import 'package:kept_aom/features/quick_title/domain/entities/quick_title_entity.dart';

abstract class QuickTitleRepository {
  Future<List<QuickTitleEntity>> fetchQuickTitles();
  Future<QuickTitleEntity?> addQuickTitle(QuickTitleEntity quicktitle);
  Future<QuickTitleEntity?> updateQuickTitle(QuickTitleEntity quicktitle);
  Future<void> updateQuickTitlesOrder(List<QuickTitleEntity> titles);
  Future<void> deleteQuickTitle(QuickTitleEntity quicktitle);
}
