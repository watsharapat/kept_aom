import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:kept_aom/core/theme/styles.dart';

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
  State<AddOrEditSavingGoalBottomSheet> createState() =>
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
    String initialName = widget.initialName ?? '';
    if (initialName.isNotEmpty && initialName.runes.length > 1) {
      _emoji = initialName.characters.first;
      _nameController = TextEditingController(
        text: initialName.substring(_emoji.length).trim(),
      );
    } else {
      _emoji = "🎯";
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
                widget.isEdit ? 'Edit Saving Goal' : 'New Saving Goal',
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
                  decoration: InputDecoration(
                    labelText: 'Goal Name',
                    hintText: 'e.g. New Car, Vacation',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                  ),
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
          const SizedBox(height: 16),
          if (widget.isEdit) ...[
            TextField(
              controller: _storedController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Current Amount',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _targetController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Target Amount',
              prefixIcon: const Icon(Icons.flag_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
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
                widget.isEdit ? 'Save Changes' : 'Create Goal',
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
