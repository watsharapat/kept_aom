import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:kept_aom/features/quick_title/domain/entities/quick_title_entity.dart';
import 'package:kept_aom/features/category/domain/entities/category_entity.dart';
import 'package:kept_aom/features/category/presentation/viewmodels/category_viewmodel.dart';
import 'package:kept_aom/features/quick_title/presentation/viewmodels/quick_title_viewmodel.dart';
import 'package:kept_aom/core/widgets/custom_toggle_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kept_aom/core/theme/styles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuickTitlePage extends ConsumerStatefulWidget {
  const QuickTitlePage({super.key});

  @override
  ConsumerState<QuickTitlePage> createState() => _QuickTitlePageState();
}

class _QuickTitlePageState extends ConsumerState<QuickTitlePage> {
  List<QuickTitleEntity>? _localQuickTitles;
  bool _hasChanges = false;
  bool _isSavingOrder = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncWithProvider();
    });
  }

  void _syncWithProvider() {
    final providerTitles = ref.read(quickTitleViewModelProvider).value ?? [];
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
      final QuickTitleEntity item = _localQuickTitles!.removeAt(oldIndex);
      _localQuickTitles!.insert(newIndex, item);
      _hasChanges = true;
    });
  }

  Future<void> _saveOrder() async {
    if (_localQuickTitles == null || !_hasChanges) return;
    
    setState(() {
      _isSavingOrder = true;
    });

    await ref
        .read(quickTitleViewModelProvider.notifier)
        .updateQuickTitlesOrder(_localQuickTitles!);
        
    if (mounted) {
      setState(() {
        _hasChanges = false;
        _isSavingOrder = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('Order saved successfully'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final quickTitlesNotifier = ref.watch(quickTitleViewModelProvider.notifier);
    final quickTitlesAsync = ref.watch(quickTitleViewModelProvider);
    final providerTitles = quickTitlesAsync.value ?? [];

    if (_localQuickTitles == null || !_hasChanges) {
      _localQuickTitles = List.from(providerTitles);
    } else if (_localQuickTitles!.length != providerTitles.length) {
      _localQuickTitles = List.from(providerTitles);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _hasChanges) {
          setState(() => _hasChanges = false);
        }
      });
    } else {
      for (int i = 0; i < _localQuickTitles!.length; i++) {
        final localItem = _localQuickTitles![i];
        final providerItem = providerTitles.firstWhere(
          (qt) => qt.id == localItem.id, 
          orElse: () => localItem,
        );
        _localQuickTitles![i] = providerItem;
      }
    }

    final userId = Supabase.instance.client.auth.currentUser!.id;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: const AppBarGradientBackground(),
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Quick Titles'),
        actions: [
          if (_hasChanges)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _isSavingOrder
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  : FilledButton.tonalIcon(
                      onPressed: _saveOrder,
                      icon: const Icon(Icons.save_rounded, size: 18),
                      label: const Text('Save'),
                    ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, top: 12, right: 20),
        child: Column(
          children: [
            Expanded(
              child: quickTitlesAsync.when(
                data: (providerTitles) {
                  final displayTitles = _localQuickTitles ?? providerTitles;
                  return displayTitles.isEmpty
                      ? const Center(child: Text('No quick titles available'))
                      : ReorderableListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          onReorder: _onReorder,
                          buildDefaultDragHandles: false,
                          itemCount: displayTitles.length,
                          itemBuilder: (context, index) {
                            final quickTitle = displayTitles[index];
                            var isDefault =
                                quickTitle.userId == null ||
                                quickTitle.userId == 'null';
                            return Padding(
                              key: ValueKey(
                                'qt_${quickTitle.id}_${quickTitle.userId}',
                              ),
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Slidable(
                                endActionPane:
                                    quickTitle.userId != 'null' &&
                                        quickTitle.userId != null
                                    ? ActionPane(
                                        motion: const DrawerMotion(),
                                        children: [
                                          SlidableAction(
                                            onPressed: (context) {
                                              showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                shape: const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                        top: Radius.circular(16),
                                                      ),
                                                ),
                                                builder: (context) => SafeArea(
                                                  child: AddOrEditQuickTitleBottomSheet(
                                                    isEdit: true,
                                                    initialTitle: quickTitle.title,
                                                    initialTypeId:
                                                        quickTitle.typeId,
                                                    initialEmoji: quickTitle.icon,
                                                    initialCategoryId:
                                                        quickTitle.categoryId,
                                                    onSubmit:
                                                        (
                                                          emoji,
                                                          title,
                                                          typeId,
                                                          categoryId,
                                                        ) async {
                                                          await quickTitlesNotifier
                                                              .updateQuickTitle(
                                                                QuickTitleEntity(
                                                                  id: quickTitle.id,
                                                                  userId: quickTitle
                                                                      .userId,
                                                                  icon: emoji,
                                                                  title: title,
                                                                  typeId: typeId,
                                                                  categoryId:
                                                                      categoryId,
                                                                  displayOrder: quickTitle.displayOrder,
                                                                ),
                                                              );
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
                                              quickTitlesNotifier.deleteQuickTitle(
                                                quickTitle,
                                              );
                                            },
                                            backgroundColor: AppColors.danger,
                                            foregroundColor:
                                                AppColors.textPrimaryOnDark,
                                            icon: Icons.delete,
                                          ),
                                        ],
                                      )
                                    : null,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(10),
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
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: isDefault ? 2 : 8,
                                    ),
                                    leading: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ReorderableDragStartListener(
                                          index: index,
                                          child: Icon(
                                            Icons.drag_indicator_rounded,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.outline,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: Center(
                                            child: Text(
                                              quickTitle.icon,
                                              style: const TextStyle(
                                                fontFamily: 'NotoEmoji',
                                                fontSize: 30,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    title: Text(
                                      quickTitle.title,
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    subtitle: isDefault
                                        ? Text(
                                            'Default',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: AppColors.textSecondary,
                                                ),
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
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
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
                        );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),
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
                onSubmit: (emoji, title, typeId, categoryId) async {
                  await quickTitlesNotifier.addQuickTitle(
                    QuickTitleEntity(
                      id: null,
                      userId: userId,
                      icon: emoji,
                      title: title,
                      typeId: typeId,
                      categoryId: categoryId,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class AddOrEditQuickTitleBottomSheet extends StatefulWidget {
  final Future<void> Function(String emoji, String title, int typeId, int? categoryId)
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
  State<AddOrEditQuickTitleBottomSheet> createState() =>
      _AddOrEditQuickTitleBottomSheetState();
}

class _AddOrEditQuickTitleBottomSheetState
    extends State<AddOrEditQuickTitleBottomSheet> {
  late TextEditingController _titleController;
  late int _typeId;
  late String _emoji;
  late bool _showEmojiPicker;
  late int? _categoryId;
  bool _isLoading = false;

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
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.isEdit ? 'Edit Quick Title' : 'Add Quick Title',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _showEmojiPicker = !_showEmojiPicker;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  height: 60,
                  width: 60,
                  child: Center(
                    child: Text(
                      _emoji,
                      style: const TextStyle(
                        fontFamily: 'NotoEmoji',
                        fontSize: 32,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _titleController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 56,
                width: 90,
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
          const SizedBox(height: 16),
          Consumer(
            builder: (context, ref, child) {
              final categories = ref.watch(categoriesByTypeProvider(_typeId));

              CategoryEntity? selectedCategory;
              if (_categoryId != null && _categoryId != 0) {
                for (final cat in categories) {
                  if (cat.categoryId == _categoryId) {
                    selectedCategory = cat;
                    break;
                  }
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Category (Optional)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (selectedCategory != null)
                        Text(
                          '${selectedCategory.icon} ${selectedCategory.name}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else
                        Text(
                          'No Category',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      Tooltip(
                        message: 'No Category',
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _categoryId = null;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 46,
                            height: 46,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _categoryId == null || _categoryId == 0
                                  ? Theme.of(context)
                                      .primaryColor
                                      .withValues(alpha: 0.15)
                                  : Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _categoryId == null || _categoryId == 0
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withValues(alpha: 0.3),
                                width: _categoryId == null || _categoryId == 0 ? 2 : 1,
                              ),
                            ),
                            child: Icon(
                              Icons.block_rounded,
                              size: 20,
                              color: _categoryId == null || _categoryId == 0
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ),
                      ),
                      ...categories.map((category) {
                        final isSelected = _categoryId == category.categoryId;

                        return Tooltip(
                          message: category.name,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _categoryId = category.categoryId;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 46,
                              height: 46,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context)
                                        .primaryColor
                                        .withValues(alpha: 0.15)
                                    : Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context)
                                          .colorScheme
                                          .outline
                                          .withValues(alpha: 0.3),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Text(
                                category.icon,
                                style: const TextStyle(
                                  fontFamily: 'NotoEmoji',
                                  fontSize: 22,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              );
            },
          ),
          if (_showEmojiPicker) ...[
            const SizedBox(height: 12),
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
                  height: 250,
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
                    iconColor:
                        Theme.of(context).textTheme.bodySmall?.color ??
                        AppColors.textPlaceholder,
                    iconColorSelected: AppColors.primary,
                    indicatorColor: AppColors.primary,
                  ),
                  bottomActionBarConfig: const BottomActionBarConfig(
                    enabled: false,
                  ),
                  searchViewConfig: const SearchViewConfig(),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: _isLoading ? null : () async {
                if (_titleController.text.trim().isNotEmpty) {
                  setState(() => _isLoading = true);
                  await widget.onSubmit(
                    _emoji,
                    _titleController.text.trim(),
                    _typeId,
                    _categoryId,
                  );
                  if (mounted) {
                    setState(() => _isLoading = false);
                    Navigator.pop(context);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Title cannot be empty')),
                  );
                }
              },
              child: _isLoading 
                  ? const SizedBox(
                      width: 24, 
                      height: 24, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : Text(
                      widget.isEdit ? 'Save Changes' : 'Add Quick Title',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
