import 'package:flutter/material.dart';
import 'package:kalorilaskuri/utils/extensions.dart';

class DateBar extends StatefulWidget {
  final ValueChanged<DateTime> onDateChanged;

  const DateBar({super.key, required this.onDateChanged});

  @override
  State<DateBar> createState() => _DateBarState();
}

class _DateBarState extends State<DateBar> {
  DateTime _date = DateTime.now();

  Future<void> _selectDate() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2026, 6, 1),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      _date = selectedDate;
      widget.onDateChanged(_date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          onPressed: () {
            _date = _date.subtract(const Duration(days: 1));
            widget.onDateChanged(_date);
          },
          icon: Icon(Icons.arrow_left),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {
                _selectDate();
              },
              icon: Icon(Icons.calendar_month),
            ),
            Text(_date.formatDate),
          ],
        ),
        IconButton(
          onPressed: () {
            _date = _date.add(const Duration(days: 1));
            widget.onDateChanged(_date);
          },
          icon: Icon(Icons.arrow_right),
        ),
      ],
    );
  }
}
