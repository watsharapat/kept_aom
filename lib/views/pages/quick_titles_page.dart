import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:kept_aom/models/quick_title_model.dart';
import 'package:kept_aom/viewmodels/category_provider.dart';
import 'package:kept_aom/viewmodels/quick_title_provider.dart';
import 'package:kept_aom/views/pages/home_page/add_transaction_page/toggle_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kept_aom/views/utils/styles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuickTitlePage extends ConsumerStatefulWidget {
  const QuickTitlePage({super.key});

  @override
  ConsumerState<QuickTitlePage> createState() => _QuickTitlePageState();
}

class _QuickTitlePageState extends ConsumerState<QuickTitlePage> {
  List<QuickTitle>? _localQuickTitles;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // Initialize local list after the first build or when data is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncWithProvider();
    });
  }

  void _syncWithProvider() {
    final providerTitles = ref.read(quickTitlesProvider).quickTitle;
    setState(() {
      _localQuickTitles = List.from(providerTitles);
      _hasChanges = false;
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (_localQuickTitles == null) return;
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final QuickTitle item = _localQuickTitles!.removeAt(oldIndex);
      _localQuickTitles!.insert(newIndex, item);
      _hasChanges = true;
    });
  }

  Future<void> _saveOrder() async {
    if (_localQuickTitles == null || !_hasChanges) return;
    await ref
        .read(quickTitlesProvider.notifier)
        .updateQuickTitlesOrder(_localQuickTitles!);
    setState(() {
      _hasChanges = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order saved successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final quickTitlesNotifier = ref.watch(quickTitlesProvider.notifier);
    final providerTitles = ref.watch(quickTitlesProvider).quickTitle;

    // If local list is null (first load) or if provider titles changed externally (e.g. after add/delete/fetch)
    // we might need to decide if we sync. However, usually we want to keep local state if there are changes.
    // For simplicity, if provider length changed (add/delete), we sync.
    if (_localQuickTitles == null ||
        (_localQuickTitles!.length != providerTitles.length && !_hasChanges)) {
      _localQuickTitles = List.from(providerTitles);
    }

    final userId = Supabase.instance.client.auth.currentUser!.id;
    final displayTitles = _localQuickTitles ?? providerTitles;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        forceMaterialTransparency: true,
        toolbarHeight: 80,
        leadingWidth: double.infinity,
        leading: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          margin:
              const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          child: Row(
            children: [
              Padding(
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(99))),
                    height: 40,
                    width: 40,
                    child: IconButton(
                        onPressed: () {
                          context.pop();
                        },
                        icon: Icon(
                          color: TextTheme.of(context).bodyMedium?.color,
                          Icons.arrow_back_rounded,
                          size: 24,
                        )),
                  )),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Quick Titles',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
              if (_hasChanges)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton.icon(
                    onPressed: _saveOrder,
                    icon: const Icon(Icons.save_rounded, size: 20),
                    label: const Text('Save'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Column(
          children: [
            Expanded(
                child: displayTitles.isEmpty
                    ? const Center(
                        child: Text('No quick titles available'),
                      )
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.only(top: 100, bottom: 80),
                        onReorder: _onReorder,
                        buildDefaultDragHandles:
                            false, // Custom drag handle used
                        itemCount: displayTitles.length,
                        itemBuilder: (context, index) {
                          final quickTitle = displayTitles[index];
                          var isDefault = quickTitle.userId == null ||
                              quickTitle.userId == 'null';
                          return Padding(
                            key: ValueKey(
                                'qt_${quickTitle.id}_${quickTitle.userId}'),
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Slidable(
                              endActionPane: quickTitle.userId != 'null' &&
                                      quickTitle.userId != null
                                  ? ActionPane(
                                      motion: const DrawerMotion(),
                                      children: [
                                        SlidableAction(
                                          onPressed: (context) {
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                        top: Radius.circular(
                                                            16)),
                                              ),
                                              builder: (context) => SafeArea(
                                                child:
                                                    AddOrEditQuickTitleBottomSheet(
                                                  isEdit: true,
                                                  initialTitle:
                                                      quickTitle.title,
                                                  initialTypeId:
                                                      quickTitle.typeId,
                                                  initialEmoji: quickTitle.icon,
                                                  initialCategoryId:
                                                      quickTitle.categoryId,
                                                  onSubmit: (emoji, title,
                                                      typeId, categoryId) {
                                                    quickTitlesNotifier
                                                        .updateQuickTitle(
                                                      QuickTitle(
                                                        id: quickTitle.id,
                                                        userId:
                                                            quickTitle.userId,
                                                        icon: emoji,
                                                        title: title,
                                                        typeId: typeId,
                                                        categoryId: categoryId,
                                                      ),
                                                    );
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                          backgroundColor: AppColors.caution,
                                          foregroundColor:
                                              AppColors.textPrimaryOnDark,
                                          icon: Icons.edit,
                                        ),
                                        SlidableAction(
                                          onPressed: (context) {
                                            quickTitlesNotifier
                                                .deleteQuickTitle(quickTitle);
                                          },
                                          backgroundColor: AppColors.danger,
                                          foregroundColor:
                                              AppColors.textPrimaryOnDark,
                                          icon: Icons.delete,
                                        ),
                                      ],
                                    )
                                  : null, // ถ้า userId == null หรือ empty ไม่ให้ slide
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                    width: 1,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                //height: 80,
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: isDefault ? 2 : 8),
                                  leading: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ReorderableDragStartListener(
                                        index: index,
                                        child: Icon(
                                          Icons.drag_indicator_rounded,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: Center(
                                          child: Text(
                                            quickTitle.icon,
                                            style:
                                                const TextStyle(fontSize: 30),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  title: Text(
                                    quickTitle.title,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  subtitle: isDefault
                                      ? Text(
                                          'Default',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                  color:
                                                      AppColors.textSecondary),
                                        )
                                      : null,
                                  style: ListTileStyle.drawer,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  trailing: Container(
                                    width: 80,
                                    height: 32,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: quickTitle.typeId == 1
                                          ? AppColors.danger.withAlpha(50)
                                          : AppColors.success.withAlpha(50),
                                      border: Border.all(
                                        color: quickTitle.typeId == 1
                                            ? AppColors.danger
                                            : AppColors.success,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      quickTitle.typeId == 1
                                          ? 'Outcome'
                                          : 'Income',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add Quick Title'),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (context) => SafeArea(
                child: AddOrEditQuickTitleBottomSheet(
              isEdit: false,
              onSubmit: (emoji, title, typeId, categoryId) {
                quickTitlesNotifier.addQuickTitle(QuickTitle(
                  id: null,
                  userId: userId, // Supabase will auto-assign the user ID
                  icon: emoji,
                  title: title,
                  typeId: typeId,
                  categoryId: categoryId,
                ));
              },
            )),
          );
        },
      ),
    );
  }
}

class AddOrEditQuickTitleBottomSheet extends StatefulWidget {
  final void Function(String emoji, String title, int typeId, int? categoryId)
      onSubmit;
  final String? initialTitle;
  final int? initialTypeId;
  final String? initialEmoji;
  final int? initialCategoryId;
  final bool isEdit;

  const AddOrEditQuickTitleBottomSheet({
    super.key,
    required this.onSubmit,
    this.initialTitle,
    this.initialTypeId,
    this.initialEmoji,
    this.initialCategoryId,
    this.isEdit = false,
  });

  @override
  _AddOrEditQuickTitleBottomSheetState createState() =>
      _AddOrEditQuickTitleBottomSheetState();
}

class _AddOrEditQuickTitleBottomSheetState
    extends State<AddOrEditQuickTitleBottomSheet> {
  late TextEditingController _titleController;
  late int _typeId;
  late String _emoji;
  late bool _showEmojiPicker;
  late int? _categoryId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _typeId = widget.initialTypeId ?? 1;
    _emoji = widget.initialEmoji ?? "😊";
    _showEmojiPicker = false;
    _categoryId = widget.initialCategoryId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.isEdit ? 'Edit Quick Title' : 'Add Quick Title',
              style: TextTheme.of(context).displaySmall),
          const SizedBox(height: 16),
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Emoji Picker Button
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                      width: 1,
                    ),
                  ),
                  height: 60,
                  width: 60,
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        _showEmojiPicker = !_showEmojiPicker;
                      });
                    },
                    child: Center(
                      child: Text(
                        _emoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Title TextField
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: 'Title',
                      hintStyle: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textPlaceholder),
                      border: Theme.of(context).inputDecorationTheme.border,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Type Toggle
                SizedBox(
                  height: 60,
                  width: 100,
                  child: CustomToggleButton(
                    selectedIndex: _typeId == 1 ? 0 : 1,
                    colors: [Theme.of(context).primaryColor],
                    onSelectionChanged: (int value) {
                      setState(() {
                        _typeId = value == 0 ? 1 : 2;
                      });
                    },
                    icons: const [
                      FaIcon(FontAwesomeIcons.upload, size: 20),
                      FaIcon(FontAwesomeIcons.download, size: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Category Selection with Choice Chips
          Consumer(
            builder: (context, ref, child) {
              final categoryNotifier = ref.watch(categoryProvider);
              final categories = categoryNotifier.getCategoriesByType(_typeId);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category (Optional)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      // No Category chip
                      ChoiceChip(
                        label: const Text('No Category'),
                        selected: _categoryId == null,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _categoryId = null;
                            });
                          }
                        },
                        selectedColor: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          color: _categoryId == null
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).textTheme.bodyMedium?.color,
                          fontWeight: _categoryId == null
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      // Category chips
                      ...categories.map((category) {
                        final isSelected = _categoryId == category.categoryId;
                        return ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                category.icon,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 6),
                              Text(category.name),
                            ],
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _categoryId = category.categoryId;
                              });
                            }
                          },
                          selectedColor: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).textTheme.bodyMedium?.color,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              );
            },
          ),
          if (_showEmojiPicker)
            SizedBox(
              height: 250,
              child: EmojiPicker(
                onEmojiSelected: (category, emoji) {
                  setState(() {
                    _emoji = emoji.emoji;
                    _showEmojiPicker = false;
                  });
                },
                config: Config(
                  height: 400,
                  checkPlatformCompatibility: true,
                  viewOrderConfig: const ViewOrderConfig(
                    top: EmojiPickerItem.categoryBar,
                    middle: EmojiPickerItem.emojiView,
                    bottom: EmojiPickerItem.searchBar,
                  ),
                  emojiViewConfig: EmojiViewConfig(
                    emojiSizeMax: 28,
                    columns: 8,
                    verticalSpacing: 8,
                    horizontalSpacing: 8,
                    backgroundColor: Theme.of(context).cardColor,
                  ),
                  skinToneConfig: const SkinToneConfig(),
                  categoryViewConfig: CategoryViewConfig(
                      dividerColor: AppColors.border,
                      backgroundColor: Theme.of(context).cardColor,
                      iconColor: Theme.of(context).textTheme.bodySmall?.color ??
                          AppColors.textPlaceholder,
                      iconColorSelected: AppColors.primary,
                      indicatorColor: AppColors.primary),
                  bottomActionBarConfig:
                      const BottomActionBarConfig(enabled: false),
                  searchViewConfig: const SearchViewConfig(),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Container(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  if (_titleController.text.trim().isNotEmpty) {
                    widget.onSubmit(
                      _emoji,
                      _titleController.text.trim(),
                      _typeId,
                      _categoryId,
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Title cannot be empty')),
                    );
                  }
                },
                child: Text(widget.isEdit ? 'Done' : 'Add',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimaryOnDark,
                        )),
              ))
        ],
      ),
    );
  }
}
