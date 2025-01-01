import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatepickerWidget extends StatefulWidget {
  final Function(DateTime) onDateChange;

  const DatepickerWidget({
    Key? key,
    required this.onDateChange,
  }) : super(key: key);

  @override
  _DatepickerWidgetState createState() => _DatepickerWidgetState();
}

class _DatepickerWidgetState extends State<DatepickerWidget> {
  DateTime _selectedDate = DateTime.now();

  void _handleDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
    widget.onDateChange(newDate);
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        style: Theme.of(context).outlinedButtonTheme.style,
        onPressed: () async {
          final DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null && pickedDate != _selectedDate) {
            _handleDateChanged(pickedDate);
          }
        },
        child: Text(
          DateFormat('yyyy-MM-dd').format(_selectedDate),
          //       style: Theme.of(context)
          //           .textTheme
          //           .bodyMedium
          //           ?.copyWith(fontWeight: FontWeight.w600)),
          // );
        ));
  }
}
