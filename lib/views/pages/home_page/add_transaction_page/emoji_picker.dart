import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:kept_aom/views/utils/styles.dart';

class EmojiPickerButton extends StatefulWidget {
  String selectedEmoji;
  final ValueChanged<String> onEmojiSelected;

  EmojiPickerButton(
      {super.key, required this.onEmojiSelected, required this.selectedEmoji});

  @override
  _EmojiPickerButtonState createState() => _EmojiPickerButtonState();
}

class _EmojiPickerButtonState extends State<EmojiPickerButton> {
  //String selectedEmoji = "💸"; // อีโมจิเริ่มต้น

  void _showEmojiPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return EmojiPicker(
          onEmojiSelected: (category, emoji) {
            setState(() {
              widget.selectedEmoji = emoji.emoji; // อัพเดทอีโมจิที่เลือก
              widget.onEmojiSelected(
                  emoji.emoji); // ส่งอีโมจิที่เลือกกลับไปยังคลาสใหญ่
            });

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
                indicatorColor: AppColors.primary),
            bottomActionBarConfig: const BottomActionBarConfig(enabled: false),
            searchViewConfig: SearchViewConfig(),
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
        //padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Center(
        child: Text(
          widget.selectedEmoji,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
