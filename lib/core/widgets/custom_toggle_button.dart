import 'package:flutter/material.dart';
import 'package:kept_aom/core/theme/styles.dart';

class CustomToggleButton extends StatefulWidget {
  final ValueChanged<int> onSelectionChanged;
  final List<Widget> icons;
  final int selectedIndex;
  final List<Color> colors;

  const CustomToggleButton({
    super.key,
    required this.onSelectionChanged,
    required this.icons,
    required this.colors,
    required this.selectedIndex,
  });

  @override
  State<CustomToggleButton> createState() => _CustomToggleButtonState();
}

class _CustomToggleButtonState extends State<CustomToggleButton> {
  int selectedValue = 0;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(CustomToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      setState(() {
        selectedValue = widget.selectedIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      onPressed: (index) {
        setState(() {
          selectedValue = index == 0 ? 0 : 1;
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
