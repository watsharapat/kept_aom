import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kept_aom/views/utils/styles.dart';

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
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
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
        child: Container(
          decoration: BoxDecoration(
            //color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              DateFormat('yMMMEd').format(_selectedDate),
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
