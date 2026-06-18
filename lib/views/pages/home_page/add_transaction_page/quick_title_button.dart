import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept_aom/models/quick_title_model.dart';
import 'package:kept_aom/viewmodels/quick_title_provider.dart';

class QuickTitleButton extends ConsumerWidget {
  final ValueChanged<QuickTitle> onTitleSelected;

  const QuickTitleButton({
    super.key,
    required this.onTitleSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The provider already fetches data in its constructor.
    // Avoid calling fetchQuickTitles() here to prevent excessive redundant API calls.
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
      builder: (context) => _QuickTitleBottomSheetContent(
        onTitleSelected: onTitleSelected,
      ),
    );
  }
}

class _QuickTitleBottomSheetContent extends ConsumerWidget {
  final ValueChanged<QuickTitle> onTitleSelected;

  const _QuickTitleBottomSheetContent({required this.onTitleSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titles = ref.watch(quickTitlesProvider).quickTitle;

    return Container(
      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 8.0),
      // Set constraints to fix scroll issues and allow dynamic height up to 80% screen
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
        minHeight: MediaQuery.of(context).size.height * 0.2, // minimum sensible height
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Wrap content height
        children: [
          // Drag handle indicator (visual hint for standard bottom sheet)
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline.withAlpha(100),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: titles.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(child: Text('No quick titles available')),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(), // Prevent bottom sheet bouncing issues
                    itemCount: titles.length,
                    itemBuilder: (context, index) {
                      final quickTitle = titles[index];
                      final titleStr = quickTitle.title;
                      final iconStr = quickTitle.icon;

                      return ListTile(
                        visualDensity: const VisualDensity(vertical: -2),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: Text(iconStr, style: const TextStyle(fontFamily: 'NotoEmoji', fontSize: 24)),
                        title: Text(
                          titleStr,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        trailing: Text(
                          quickTitle.typeId == 2
                              ? 'Income'
                              : quickTitle.typeId == 1
                                  ? 'Expense'
                                  : 'Transfer',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context); // Close the bottom sheet
                          onTitleSelected(quickTitle); // Trigger the callback
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}


