import 'package:flutter/material.dart';
import 'package:kalorilaskuri/utils/extensions.dart';

class MealsPage extends StatefulWidget {
  const MealsPage({super.key});

  @override
  State<MealsPage> createState() => _MealsPageState();
}

class _MealsPageState extends State<MealsPage> {
  DateTime date = DateTime.now();

  void _addNewMeal() {}

  Future<void> _selectDate() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2026, 6, 1),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        date = selectedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    date = date.subtract(const Duration(days: 1));
                  });
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
                  Text(date.formatDate),
                ],
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    date = date.add(const Duration(days: 1));
                  });
                },
                icon: Icon(Icons.arrow_right),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewMeal,
        tooltip: 'Lisää ateria',
        child: const Icon(Icons.add),
      ),
    );
  }
}
