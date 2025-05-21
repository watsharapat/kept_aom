import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kept_aom/viewmodels/quick_title_provider.dart';
import 'package:kept_aom/views/pages/home_page/add_transaction_page/emoji_picker.dart';
import 'package:kept_aom/views/pages/home_page/add_transaction_page/toggle_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kept_aom/views/utils/styles.dart';

class QuickTitlePage extends ConsumerWidget {
  const QuickTitlePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quickTitlesNotifier = ref.watch(quickTitlesProvider.notifier);
    final quickTitles = ref.watch(quickTitlesProvider).quickTitle;

    return Scaffold(
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          forceMaterialTransparency: true,
          toolbarHeight: 80,
          leadingWidth: 240,
          leading: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(99),
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
                )
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Column(
              children: [
                Expanded(
                  child: quickTitles.isEmpty
                      ? const Center(
                          child: Text('No quick titles available'),
                        )
                      : ListView.builder(
                          itemCount: quickTitles.length,
                          itemBuilder: (context, index) {
                            final quickTitle = quickTitles[index];
                            String emojiFromTitle =
                                quickTitle.title.split(' ')[0];
                            String titleWithoutEmoji = quickTitle.title
                                .split(' ')
                                .sublist(1)
                                .join(' ');
                            return Builder(
                              builder: (tileContext) {
                                return GestureDetector(
                                  onLongPress: () async {
                                    final RenderBox overlay =
                                        Overlay.of(context)
                                            .context
                                            .findRenderObject() as RenderBox;
                                    final RenderBox tileBox = tileContext
                                        .findRenderObject() as RenderBox;
                                    final Offset tilePosition =
                                        tileBox.localToGlobal(Offset.zero,
                                            ancestor: overlay);

                                    // The delete/edit menu only shows if quickTitle.userId != 'null'
                                    // If quickTitle.userId is 'null' or empty, the menu won't show
                                    if (quickTitle.userId != 'null' &&
                                        quickTitle.userId.isNotEmpty) {
                                      await showMenu(
                                        surfaceTintColor:
                                            Theme.of(context).canvasColor,
                                        color: Theme.of(context).cardColor,
                                        shadowColor: AppColors.netural,
                                        constraints:
                                            const BoxConstraints.expand(
                                          width: double.infinity,
                                          height: 128,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        context: context,
                                        position: RelativeRect.fromLTRB(
                                          tilePosition.dx + tileBox.size.width,
                                          tilePosition.dy + tileBox.size.height,
                                          tilePosition.dx + tileBox.size.width,
                                          tilePosition.dy,
                                        ),
                                        items: [
                                          PopupMenuItem(
                                            value: 'edit',
                                            child: ListTile(
                                              titleAlignment:
                                                  ListTileTitleAlignment.center,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              leading: const Icon(
                                                Icons.edit,
                                                color: AppColors.caution,
                                              ),
                                              title: const Text('Edit'),
                                              onTap: () {
                                                showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                            top:
                                                                Radius.circular(
                                                                    16)),
                                                  ),
                                                  builder: (context) => SafeArea(
                                                      child: AddOrEditQuickTitleBottomSheet(
                                                    isEdit: true,
                                                    initialTitle:
                                                        titleWithoutEmoji,
                                                    initialTypeId:
                                                        quickTitle.typeId,
                                                    initialEmoji:
                                                        emojiFromTitle,
                                                    onSubmit:
                                                        (emoji, title, typeId) {
                                                      quickTitlesNotifier
                                                          .updateQuickTitle(
                                                              quickTitle.title,
                                                              title,
                                                              typeId);
                                                      Navigator.pop(context);
                                                    },
                                                  )),
                                                );
                                              },
                                            ),
                                          ),
                                          PopupMenuItem(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            value: 'delete',
                                            child: ListTile(
                                              titleAlignment:
                                                  ListTileTitleAlignment.center,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              leading: const Icon(
                                                Icons.delete,
                                                color: AppColors.danger,
                                              ),
                                              title: const Text('Delete'),
                                              onTap: () {
                                                quickTitlesNotifier
                                                    .deleteQuickTitle(
                                                        quickTitle.title);
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 10,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    height: 80,
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 4),
                                      leading: Container(
                                        width: 60,
                                        height: 60,
                                        child: Text(
                                          emojiFromTitle,
                                          style: const TextStyle(fontSize: 30),
                                        ),
                                      ),
                                      title: Text(titleWithoutEmoji),
                                      subtitle: Text(
                                        quickTitle.userId.isEmpty ||
                                                quickTitle.userId == 'null'
                                            ? 'Default'
                                            : '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                                color: AppColors.textSecondary),
                                      ),
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
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          quickTitle.typeId == 1
                                              ? 'Outcome'
                                              : 'Income',
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
                FloatingActionButton.extended(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Quick Title'),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (context) => SafeArea(
                          child: AddOrEditQuickTitleBottomSheet(
                        isEdit: false,
                        onSubmit: (emoji, title, typeId) {
                          quickTitlesNotifier.addQuickTitle(
                              emoji, title, typeId);
                        },
                      )),
                    );
                  },
                ),
              ],
            ),
          ),
        ));
  }
}

class AddOrEditQuickTitleBottomSheet extends StatefulWidget {
  final void Function(String emoji, String title, int typeId) onSubmit;
  final String? initialTitle;
  final int? initialTypeId;
  final String? initialEmoji;
  final bool isEdit;

  const AddOrEditQuickTitleBottomSheet({
    super.key,
    required this.onSubmit,
    this.initialTitle,
    this.initialTypeId,
    this.initialEmoji,
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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _typeId = widget.initialTypeId ?? 1;
    _emoji = widget.initialEmoji ?? "😊";
    _showEmojiPicker = false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                      color: AppColors.border,
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
