import 'package:flutter/material.dart';
import 'package:kalorilaskuri/utils/extensions.dart';

class AddCaloriesDialog extends StatefulWidget {
  const AddCaloriesDialog({super.key});

  @override
  State<AddCaloriesDialog> createState() => _AddCaloriesDialogState();
}

class _AddCaloriesDialogState extends State<AddCaloriesDialog> {
  final _formKey = GlobalKey<FormState>();
  final _caloriesController = TextEditingController();

  late DateTime _selectedDate;

  @override
  void initState() {
    final now = DateTime.now();
    _selectedDate = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 1));
    super.initState();
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2026, 6, 1),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Lisää kulutetut kalorit'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Kalorit'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Anna kalorit';
                }

                final number = int.tryParse(value);

                if (number == null || number <= 0) {
                  return 'Anna kalorit positiivisena lukuna';
                }

                return null;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: selectDate,
                child: Text(_selectedDate.formatDate),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Sulje'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              return;
            }

            final calories = int.parse(_caloriesController.text);

            Navigator.pop(context, {
              'calories': calories,
              'date': _selectedDate,
            });
          },
          child: const Text('Tallenna'),
        ),
      ],
    );
  }
}
