import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept_aom/core/theme/styles.dart';
import 'package:kept_aom/features/category/domain/entities/category_entity.dart';
import 'package:kept_aom/features/category/presentation/viewmodels/category_viewmodel.dart';
import 'package:kept_aom/features/quick_title/domain/entities/quick_title_entity.dart';
import 'package:kept_aom/features/quick_title/presentation/viewmodels/quick_title_viewmodel.dart';

class QuickTitleButton extends ConsumerWidget {
  final ValueChanged<QuickTitleEntity> onTitleSelected;

  const QuickTitleButton({super.key, required this.onTitleSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      onPressed: () => _showQuickTitleSheet(context, ref),
      icon: const Icon(Icons.arrow_drop_down_circle_rounded),
    );
  }

  void _showQuickTitleSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _QuickTitleBottomSheetContent(onTitleSelected: onTitleSelected),
    );
  }
}

class _QuickTitleBottomSheetContent extends ConsumerWidget {
  final ValueChanged<QuickTitleEntity> onTitleSelected;

  const _QuickTitleBottomSheetContent({required this.onTitleSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titlesAsync = ref.watch(quickTitleViewModelProvider);
    final titles = titlesAsync.value ?? [];
    final categoriesAsync = ref.watch(categoryViewModelProvider);
    final categories = categoriesAsync.value ?? [];

    CategoryEntity? getCategory(int? id) {
      if (id == null || id == 0) return null;
      for (final cat in categories) {
        if (cat.categoryId == id) return cat;
      }
      return null;
    }

    final Map<int?, List<QuickTitleEntity>> grouped = {};
    for (final title in titles) {
      final catId = (title.categoryId != null && title.categoryId != 0)
          ? title.categoryId
          : null;
      grouped.putIfAbsent(catId, () => []).add(title);
    }

    final List<int?> categoryOrder = [];
    for (final cat in categories) {
      if (grouped.containsKey(cat.categoryId)) {
        categoryOrder.add(cat.categoryId);
      }
    }
    for (final catId in grouped.keys) {
      if (catId != null && !categoryOrder.contains(catId)) {
        categoryOrder.add(catId);
      }
    }
    if (grouped.containsKey(null)) {
      categoryOrder.add(null);
    }

    final leftCatIds = <int?>[];
    final rightCatIds = <int?>[];
    for (int i = 0; i < categoryOrder.length; i++) {
      if (i % 2 == 0) {
        leftCatIds.add(categoryOrder[i]);
      } else {
        rightCatIds.add(categoryOrder[i]);
      }
    }

    return Container(
      padding: const EdgeInsets.only(
        top: 16.0,
        left: 16.0,
        right: 16.0,
        bottom: 8.0,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
        minHeight: MediaQuery.of(context).size.height * 0.2,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(100),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline.withAlpha(100),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            'เลือก Quick Title',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: titles.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(child: Text('No quick titles available')),
                  )
                : SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: leftCatIds.map((catId) {
                              return _buildFolderCard(
                                context,
                                catId,
                                grouped[catId] ?? [],
                                getCategory(catId),
                                onTitleSelected,
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            children: rightCatIds.map((catId) {
                              return _buildFolderCard(
                                context,
                                catId,
                                grouped[catId] ?? [],
                                getCategory(catId),
                                onTitleSelected,
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderCard(
    BuildContext context,
    int? catId,
    List<QuickTitleEntity> catTitles,
    CategoryEntity? category,
    ValueChanged<QuickTitleEntity> onTitleSelected,
  ) {
    final categoryName = category?.name ?? 'ไม่มีหมวดหมู่';
    final categoryIcon = category?.icon ?? '📁';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final folderBg = isDark
        ? Colors.white.withAlpha(12)
        : Theme.of(context).colorScheme.outline.withAlpha(15);
    final folderBorder = Theme.of(context).colorScheme.outline.withAlpha(40);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: folderBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: folderBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Samsung One UI Folder Header (Clear & Readable)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).primaryColor.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        categoryIcon,
                        style: const TextStyle(
                          fontFamily: 'NotoEmoji',
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        categoryName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${catTitles.length}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Items inside folder arranged in a Grid/Wrap like One UI app icons
          LayoutBuilder(
            builder: (context, constraints) {
              final double itemWidth = (constraints.maxWidth - 8) / 2;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: catTitles.map((quickTitle) {
                  final titleStr = quickTitle.title;
                  final iconStr = quickTitle.icon;
                  final typeColor = quickTitle.typeId == 2
                      ? AppColors.success
                      : quickTitle.typeId == 1
                      ? AppColors.danger
                      : Theme.of(context).colorScheme.primary;

                  return InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      onTitleSelected(quickTitle);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: itemWidth.clamp(56.0, 100.0),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withAlpha(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            iconStr,
                            style: const TextStyle(
                              fontFamily: 'NotoEmoji',
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            titleStr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 12,
                            height: 3,
                            decoration: BoxDecoration(
                              color: typeColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
