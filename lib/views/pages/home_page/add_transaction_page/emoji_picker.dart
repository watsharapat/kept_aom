import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_emoji_picker/keyboard_emoji_picker.dart';

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
          side: BorderSide(width: 1, color: Colors.black45),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Center(
        child: Text(
          widget.selectedEmoji,
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
