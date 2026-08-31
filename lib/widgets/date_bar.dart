import 'package:flutter/material.dart';
import 'package:kalorilaskuri/utils/extensions.dart';

class DateBar extends StatefulWidget {
  final ValueChanged<DateTime> onDateChanged;
  final Widget child;

  const DateBar({super.key, required this.onDateChanged, required this.child});

  @override
  State<DateBar> createState() => _DateBarState();
}

class _DateBarState extends State<DateBar> {
  DateTime _date = DateTime.now();
  double offset = 0;

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
    return Column(
      children: [
        Container(
          color: context.surface,
          child: Row(
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
          ),
        ),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: (details) {
              setState(() {
                offset += details.delta.dx;
              });
            },
            onHorizontalDragEnd: (details) {
              DateTime newDate = _date;
              if (offset < -100) {
                newDate = _date.add(const Duration(days: 1));
              } else if (offset > 100) {
                newDate = _date.subtract(const Duration(days: 1));
              }

              setState(() {
                offset = 0;
                _date = newDate;
                widget.onDateChanged(_date);
              });
            },
            child: Transform.translate(
              offset: Offset(offset, 0),
              child: widget.child,
            ),
          ),
        ),
      ],
    );
  }
}
