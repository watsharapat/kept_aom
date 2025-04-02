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
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: DateFormat('yMMMEd').format(_selectedDate),
    );
  }

  void _handleDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
      _controller.text = DateFormat('yMMMEd').format(newDate);
    });
    widget.onDateChange(newDate);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        fillColor: Theme.of(context).cardColor,
        labelStyle: Theme.of(context).textTheme.bodyMedium,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), // Custom border radius
          borderSide:
              const BorderSide(color: Colors.red), // Custom border color
        ),
      ),
      textAlign: TextAlign.center,
      controller: _controller,
      readOnly: true,
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null && pickedDate != _selectedDate) {
          _handleDateChanged(pickedDate);
        }
      },
    );
  }
}
