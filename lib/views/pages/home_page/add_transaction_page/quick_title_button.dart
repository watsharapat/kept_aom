import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept_aom/viewmodels/quick_title_provider.dart';

class QuickTitleButton extends ConsumerWidget {
  const QuickTitleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () => _showQuickTitleSheet(context, ref),
      icon: const Icon(Icons.arrow_drop_down_circle_rounded),
    );
  }

  void _showQuickTitleSheet(BuildContext context, WidgetRef ref) {
    final provider = ref.read(quickTitlesProvider);

    provider.fetchQuickTitles();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: provider.quickTitle.length,
            itemBuilder: (context, index) {
              final title = provider.quickTitle[index].title ?? 'Untitled';
              return ListTile(
                title: Text(title),
                onTap: () {
                  Navigator.pop(context, title); // Return selected title
                },
              );
            },
          ),
        );
      },
    );
  }
}
