import 'package:flutter/material.dart';
import 'package:kept_aom/views/utils/styles.dart';

class CustomToggleButton extends StatefulWidget {
  final ValueChanged<int> onSelectionChanged;
  final List<Widget> icons;

  final List<Color> colors;

  const CustomToggleButton(
      {super.key,
      required this.onSelectionChanged,
      required this.icons,
      required this.colors});

  @override
  _CustomToggleButtonState createState() => _CustomToggleButtonState();
}

class _CustomToggleButtonState extends State<CustomToggleButton> {
  int selectedValue = 0;

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      onPressed: (index) {
        setState(() {
          if (index == 0) {
            selectedValue = 0;
          } else {
            selectedValue = 1;
          }
        });
        widget.onSelectionChanged(selectedValue);
      },
      isSelected: [selectedValue == 0, selectedValue == 1],
      borderRadius: BorderRadius.circular(12),
      fillColor: widget.colors[0],
      selectedColor: Colors.white,
      color: AppColors.disabledWidget,
      children: widget.icons,
    );
  }
}
