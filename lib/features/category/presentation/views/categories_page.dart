import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:kept_aom/features/category/domain/entities/category_entity.dart';
import 'package:kept_aom/features/category/presentation/viewmodels/category_viewmodel.dart';
import 'package:kept_aom/core/widgets/custom_toggle_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kept_aom/core/theme/styles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key});

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryViewModelProvider.notifier).fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryViewModelProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;

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
        title: const Text('Categories'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, top: 12, right: 20),
        child: Column(
          children: [
            Expanded(
              child: categoriesAsync.when(
                data: (categories) => categories.isEmpty
                    ? const Center(child: Text('No categories available'))
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          var isDefault =
                              category.userId == 'null' || category.userId.isEmpty;

                          return Padding(
                            key: ValueKey('cat_${category.categoryId}'),
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Slidable(
                              endActionPane: !isDefault && category.userId == userId
                                  ? ActionPane(
                                      motion: const DrawerMotion(),
                                      children: [
                                        SlidableAction(
                                          onPressed: (context) {
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.vertical(
                                                  top: Radius.circular(16),
                                                ),
                                              ),
                                              builder: (context) => SafeArea(
                                                child: AddOrEditCategoryBottomSheet(
                                                  isEdit: true,
                                                  initialName: category.name,
                                                  initialTypeId: category.typeId,
                                                  initialEmoji: category.icon,
                                                  onSubmit: (emoji, name, typeId) async {
                                                    await ref
                                                        .read(categoryViewModelProvider.notifier)
                                                        .updateCategory(
                                                          CategoryEntity(
                                                            categoryId: category.categoryId,
                                                            userId: category.userId,
                                                            icon: emoji,
                                                            name: name,
                                                            typeId: typeId,
                                                          ),
                                                        );
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                          backgroundColor: AppColors.caution,
                                          foregroundColor: AppColors.textPrimaryOnDark,
                                          icon: Icons.edit,
                                        ),
                                        SlidableAction(
                                          onPressed: (context) {
                                            ref
                                                .read(categoryViewModelProvider.notifier)
                                                .deleteCategory(category);
                                          },
                                          backgroundColor: AppColors.danger,
                                          foregroundColor: AppColors.textPrimaryOnDark,
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
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: Center(
                                          child: Text(
                                            category.icon,
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
                                    category.name,
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
                                      color: category.typeId == 1
                                          ? AppColors.danger.withAlpha(50)
                                          : AppColors.success.withAlpha(50),
                                      border: Border.all(
                                        color: category.typeId == 1
                                            ? AppColors.danger
                                            : AppColors.success,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      category.typeId == 1 ? 'Expense' : 'Income',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (context) => SafeArea(
              child: AddOrEditCategoryBottomSheet(
                isEdit: false,
                onSubmit: (emoji, name, typeId) async {
                  await ref.read(categoryViewModelProvider.notifier).addCategory(
                        CategoryEntity(
                          categoryId: 0,
                          userId: userId ?? '',
                          icon: emoji,
                          name: name,
                          typeId: typeId,
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

class AddOrEditCategoryBottomSheet extends StatefulWidget {
  final Future<void> Function(String emoji, String name, int typeId) onSubmit;
  final String? initialName;
  final int? initialTypeId;
  final String? initialEmoji;
  final bool isEdit;

  const AddOrEditCategoryBottomSheet({
    super.key,
    required this.onSubmit,
    this.initialName,
    this.initialTypeId,
    this.initialEmoji,
    this.isEdit = false,
  });

  @override
  State<AddOrEditCategoryBottomSheet> createState() =>
      _AddOrEditCategoryBottomSheetState();
}

class _AddOrEditCategoryBottomSheetState extends State<AddOrEditCategoryBottomSheet> {
  late TextEditingController _nameController;
  late int _typeId;
  late String _emoji;
  late bool _showEmojiPicker;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _typeId = widget.initialTypeId ?? 1;
    _emoji = widget.initialEmoji ?? "📁";
    _showEmojiPicker = false;
  }

  @override
  void dispose() {
    _nameController.dispose();
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
                widget.isEdit ? 'Edit Category' : 'Add Category',
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
                  controller: _nameController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Category Name',
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
                if (_nameController.text.trim().isNotEmpty) {
                  setState(() => _isLoading = true);
                  await widget.onSubmit(
                    _emoji,
                    _nameController.text.trim(),
                    _typeId,
                  );
                  if (mounted) {
                    setState(() => _isLoading = false);
                    Navigator.pop(context);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name cannot be empty')),
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
                      widget.isEdit ? 'Save Changes' : 'Add Category',
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
