import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:kept_aom/core/theme/styles.dart';

class EmojiPickerButton extends StatefulWidget {
  final String selectedEmoji;
  final ValueChanged<String> onEmojiSelected;

  const EmojiPickerButton({
    super.key,
    required this.onEmojiSelected,
    required this.selectedEmoji,
  });

  @override
  State<EmojiPickerButton> createState() => _EmojiPickerButtonState();
}

class _EmojiPickerButtonState extends State<EmojiPickerButton> {
  late String _currentEmoji;

  @override
  void initState() {
    super.initState();
    _currentEmoji = widget.selectedEmoji;
  }

  @override
  void didUpdateWidget(EmojiPickerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedEmoji != oldWidget.selectedEmoji) {
      _currentEmoji = widget.selectedEmoji;
    }
  }

  void _showEmojiPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return EmojiPicker(
          onEmojiSelected: (category, emoji) {
            setState(() {
              _currentEmoji = emoji.emoji;
            });
            widget.onEmojiSelected(emoji.emoji);
            Navigator.pop(context);
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
              indicatorColor: AppColors.primary,
            ),
            bottomActionBarConfig: const BottomActionBarConfig(enabled: false),
            searchViewConfig: const SearchViewConfig(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => _showEmojiPicker(context),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Center(
        child: Text(
          _currentEmoji,
          style: const TextStyle(fontFamily: 'NotoEmoji', fontSize: 24),
        ),
      ),
    );
  }
}
