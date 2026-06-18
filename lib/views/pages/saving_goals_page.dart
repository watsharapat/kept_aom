import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kept_aom/viewmodels/saving_goals_provider.dart';
import 'package:kept_aom/views/utils/styles.dart';
import 'package:kept_aom/utils/format_utils.dart';

class SavingGoalsPage extends ConsumerWidget {
  const SavingGoalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savingGoalsNotifier = ref.watch(savingGoalsProvider.notifier);
    final savingGoals = ref.watch(savingGoalsProvider).savingGoals;

    String statusText(int statusId) {
      switch (statusId) {
        case 2:
          return 'Completed';
        case 1:
          return 'On going';
        default:
          return 'On going';
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        flexibleSpace: const AppBarGradientBackground(),
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Saving Goals'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20,
            top: 12,
            right: 20,
            bottom: 16,
          ),
          child: Column(
            children: [
              Expanded(
                child: savingGoals.isEmpty
                    ? const Center(child: Text('No saving goals available'))
                    : ListView.builder(
                        itemCount: savingGoals.length,
                        itemBuilder: (context, index) {
                          final savingGoal = savingGoals[index];
                          return Builder(
                            builder: (tileContext) {
                              return GestureDetector(
                                onLongPress: () async {
                                  final RenderBox overlay =
                                      Overlay.of(
                                            context,
                                          ).context.findRenderObject()
                                          as RenderBox;
                                  final RenderBox tileBox =
                                      tileContext.findRenderObject()
                                          as RenderBox;
                                  final Offset tilePosition = tileBox
                                      .localToGlobal(
                                        Offset.zero,
                                        ancestor: overlay,
                                      );

                                  if (savingGoal.userId.isNotEmpty) {
                                    await showMenu(
                                      surfaceTintColor: Theme.of(
                                        context,
                                      ).canvasColor,
                                      color: Theme.of(context).cardColor,
                                      shadowColor: AppColors.netural,
                                      constraints: const BoxConstraints.expand(
                                        width: double.infinity,
                                        height: 128,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
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
                                                  horizontal: 16,
                                                ),
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
                                                                  16,
                                                                ),
                                                          ),
                                                    ),
                                                builder: (context) => SafeArea(
                                                  child: AddOrEditSavingGoalBottomSheet(
                                                    isEdit: true,
                                                    initialName:
                                                        savingGoal.name,
                                                    initialStored:
                                                        savingGoal.stored,
                                                    initialTarget:
                                                        savingGoal.target,
                                                    onSubmit:
                                                        (name, stored, target) {
                                                          savingGoalsNotifier
                                                              .updateSavingGoals(
                                                                oldName:
                                                                    savingGoal
                                                                        .name,
                                                                name: name,
                                                                stored: stored,
                                                                target: target,
                                                              );
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                        },
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        PopupMenuItem(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          value: 'delete',
                                          child: ListTile(
                                            titleAlignment:
                                                ListTileTitleAlignment.center,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                ),
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
                                              savingGoalsNotifier
                                                  .deleteSavingGoals(
                                                    savingGoal.name,
                                                  );
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
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outline,
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
                                  height: 100,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    title: Row(
                                      children: [
                                        Text(
                                          savingGoal.name.isNotEmpty
                                              ? savingGoal.name.characters.first
                                              : "ðŸŽ¯",
                                          style: const TextStyle(
                                            fontFamily: 'NotoEmoji',
                                            fontSize: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            savingGoal.name.characters
                                                .skip(1)
                                                .toString()
                                                .trim(),
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Row(
                                      children: [
                                        Text(
                                          'Status: ${statusText(savingGoal.statusId)}',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                        const SizedBox(width: 16),
                                        Text(
                                          '${FormatUtils.formatNumber(savingGoal.stored.toDouble())}/${FormatUtils.formatNumber(savingGoal.target.toDouble())}',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                    style: ListTileStyle.drawer,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    trailing: SizedBox(
                                      width:
                                          40, // à¸à¸³à¸«à¸™à¸”à¸„à¸§à¸²à¸¡à¸à¸§à¹‰à¸²à¸‡à¸ªà¸¹à¸‡à¸ªà¸¸à¸”à¹ƒà¸«à¹‰ trailing
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${((savingGoal.stored / (savingGoal.target == 0 ? 1 : savingGoal.target)) * 100).toStringAsFixed(1)}%',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          LinearProgressIndicator(
                                            value: savingGoal.target == 0
                                                ? 0
                                                : savingGoal.stored /
                                                      savingGoal.target,
                                            backgroundColor: AppColors.border,
                                            color: AppColors.primary,
                                            minHeight: 6,
                                          ),
                                        ],
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
                label: const Text('Add Saving Goal'),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    builder: (context) => SafeArea(
                      child: AddOrEditSavingGoalBottomSheet(
                        isEdit: false,
                        onSubmit: (name, stored, target) {
                          savingGoalsNotifier.addSavingGoals(
                            name: name,
                            target: target,
                            stored: stored,
                          );
                          savingGoalsNotifier.fetchSavingGoals();
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddOrEditSavingGoalBottomSheet extends StatefulWidget {
  final void Function(String name, int stored, int target) onSubmit;
  final String? initialName;
  final int? initialStored;
  final int? initialTarget;
  final bool isEdit;

  const AddOrEditSavingGoalBottomSheet({
    super.key,
    required this.onSubmit,
    this.initialName,
    this.initialStored,
    this.initialTarget,
    this.isEdit = false,
  });

  @override
  _AddOrEditSavingGoalBottomSheetState createState() =>
      _AddOrEditSavingGoalBottomSheetState();
}

class _AddOrEditSavingGoalBottomSheetState
    extends State<AddOrEditSavingGoalBottomSheet> {
  late TextEditingController _nameController;
  late TextEditingController _storedController;
  late TextEditingController _targetController;
  late String _emoji;
  bool _showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    // à¸–à¹‰à¸²à¸¡à¸µ emoji à¸™à¸³à¸«à¸™à¹‰à¸² initialName à¹ƒà¸«à¹‰à¹à¸¢à¸ emoji à¸­à¸­à¸
    String initialName = widget.initialName ?? '';
    if (initialName.isNotEmpty && initialName.runes.length > 1) {
      _emoji = initialName.characters.first;
      _nameController = TextEditingController(
        text: initialName.substring(_emoji.length).trim(),
      );
    } else {
      _emoji = "ðŸŽ¯";
      _nameController = TextEditingController(text: initialName);
    }
    _storedController = TextEditingController(
      text: widget.initialStored?.toString() ?? '0',
    );
    _targetController = TextEditingController(
      text: widget.initialTarget?.toString() ?? '0',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _storedController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
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
          Text(
            widget.isEdit ? 'Edit Saving Goal' : 'Add Saving Goal',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
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
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                      width: 1,
                    ),
                  ),
                  height: 56,
                  width: 56,
                  child: Center(
                    child: Text(
                      _emoji,
                      style: const TextStyle(
                        fontFamily: 'NotoEmoji',
                        fontSize: 28,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter saving goal name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
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
          const SizedBox(height: 12),
          if (widget.isEdit)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _storedController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Stored',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _targetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Target',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            )
          else
            TextField(
              controller: _targetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Target',
                border: OutlineInputBorder(),
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
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
                if (_nameController.text.trim().isNotEmpty) {
                  String nameToSave = '$_emoji ${_nameController.text.trim()}';
                  if (widget.isEdit) {
                    widget.onSubmit(
                      nameToSave,
                      int.tryParse(_storedController.text.trim()) ?? 0,
                      int.tryParse(_targetController.text.trim()) ?? 0,
                    );
                  } else {
                    widget.onSubmit(
                      nameToSave,
                      0,
                      int.tryParse(_targetController.text.trim()) ?? 0,
                    );
                  }
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name cannot be empty')),
                  );
                }
              },
              child: Text(
                widget.isEdit ? 'Done' : 'Add',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimaryOnDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
