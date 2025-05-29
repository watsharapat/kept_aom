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
    final provider = ref.read(quickTitlesProvider);
    provider.fetchQuickTitles();
    return IconButton(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      onPressed: () => _showQuickTitleSheet(context, ref),
      icon: const Icon(Icons.arrow_drop_down_circle_rounded),
    );
  }

  void _showQuickTitleSheet(BuildContext context, WidgetRef ref) {
    final provider = ref.read(quickTitlesProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          height: MediaQuery.of(context).size.height * 0.4,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: provider.quickTitle.length,
            itemBuilder: (context, index) {
              final title = provider.quickTitle[index].title ?? '💸 Untitled';
              final quickTitle = provider.quickTitle[index];
              return ListTile(
                visualDensity: const VisualDensity(vertical: -2),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Text(title.split(' ')[0],
                    style: const TextStyle(fontSize: 24)),
                title: Text(
                  title.split(' ').sublist(1).join(' '),
                  style: TextTheme.of(context).bodyMedium,
                ),
                trailing: Text(
                  quickTitle.typeId == 2
                      ? 'Income'
                      : quickTitle.typeId == 1
                          ? 'Expense'
                          : 'Transfer',
                  style: TextTheme.of(context).bodyMedium,
                ),
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet
                  onTitleSelected(quickTitle); // Trigger the callback
                },
              );
            },
          ),
        );
      },
    );
  }
}
