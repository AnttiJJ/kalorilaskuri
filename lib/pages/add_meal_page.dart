import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kalorilaskuri/db/firestore_util.dart';
import 'package:kalorilaskuri/db/meal.dart';
import 'package:kalorilaskuri/db/sqflite_util.dart';

class AddMealPage extends StatefulWidget {
  const AddMealPage({super.key});

  @override
  State<AddMealPage> createState() => _AddMealPageState();
}

class _AddMealPageState extends State<AddMealPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _weightController = TextEditingController();
  final _amountController = TextEditingController();

  String _type = 'Ateria';
  String _mealSizeType = 'Paino';
  String? _mealSize;
  DateTime? _datetime;

  @override
  void initState() {
    _datetime = DateTime.now();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _weightController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> saveMeal() async {
    final name = _nameController.text;
    final calories = int.parse(_caloriesController.text);
    final weight = _mealSizeType == 'Paino'
        ? int.parse(_weightController.text)
        : null;
    final size = _mealSizeType == 'Koko' ? _mealSize : null;
    final amount = _mealSizeType == 'Määrä'
        ? int.parse(_amountController.text)
        : null;

    DateTime date = DateTime.now();

    if (!isSameDate(date, _datetime!)) {
      date = _datetime!;
    }

    final Meal meal = Meal(
      name: name,
      calories: calories,
      type: _type,
      weight: weight,
      size: size,
      amount: amount,
      createdAt: date.toIso8601String(),
      fromMenu: 0,
    );

    try {
      final FirestoreUtil firestoreUtil = FirestoreUtil();
      await firestoreUtil.addCalories(calories, _type, date);

      final SqfliteUtil sqfliteUtil = SqfliteUtil();
      await sqfliteUtil.insertMeal(meal);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      print(e);
      return;
    }
  }

  Future<void> selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _datetime ?? DateTime.now(),
      firstDate: DateTime(2026, 6, 1),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _datetime = date;
      });
    }
  }

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Uusi ateria'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Aterian nimi'),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Anna aterian nimi';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Column(
                children: [
                  OutlinedButton(
                    onPressed: selectDate,
                    child: Text(
                      '${_datetime!.day.toString().padLeft(2, '0')}.'
                      '${_datetime!.month.toString().padLeft(2, '0')}.'
                      '${_datetime!.year}',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _caloriesController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
              SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Ateria'),
                    selected: _type == 'Ateria',
                    onSelected: (value) {
                      setState(() {
                        _type = 'Ateria';
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Välipala'),
                    selected: _type == 'Välipala',
                    onSelected: (value) {
                      setState(() {
                        _type = 'Välipala';
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Herkku'),
                    selected: _type == 'Herkku',
                    onSelected: (value) {
                      setState(() {
                        _type = 'Herkku';
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Lisuke'),
                    selected: _type == 'Lisuke',
                    onSelected: (value) {
                      setState(() {
                        _type = 'Lisuke';
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Juoma'),
                    selected: _type == 'Juoma',
                    onSelected: (value) {
                      setState(() {
                        _type = 'Juoma';
                      });
                    },
                  ),
                ],
              ),
              // SegmentedButton(
              //   segments: const [
              //     ButtonSegment(value: 'Ateria', label: Text('Ateria')),
              //     ButtonSegment(value: 'Välipala', label: Text('Välipala')),
              //     ButtonSegment(value: 'Herkku', label: Text('Herkku')),
              //   ],
              //   selected: {_type},
              //   onSelectionChanged: (selection) {
              //     setState(() {
              //       _type = selection.first;
              //     });
              //   },
              // ),
              SizedBox(height: 20),
              SegmentedButton(
                segments: const [
                  ButtonSegment(value: 'Paino', label: Text('Paino')),
                  ButtonSegment(value: 'Koko', label: Text('Koko')),
                  ButtonSegment(value: 'Määrä', label: Text('Määrä')),
                ],
                selected: {_mealSizeType},
                onSelectionChanged: (selection) {
                  setState(() {
                    _mealSizeType = selection.first;
                  });
                },
              ),
              if (_mealSizeType == 'Paino')
                TextFormField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Paino grammoina',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Anna paino';
                    }

                    final number = int.tryParse(value);

                    if (number == null || number <= 0) {
                      return 'Anna paino positiivisena lukuna';
                    }

                    return null;
                  },
                ),
              if (_mealSizeType == 'Koko')
                DropdownButtonFormField(
                  decoration: const InputDecoration(labelText: 'Aterian koko'),
                  initialValue: 'Pieni',
                  items: const [
                    DropdownMenuItem(value: 'Pieni', child: Text('Pieni')),
                    DropdownMenuItem(
                      value: 'Normaali',
                      child: Text('Normaali'),
                    ),
                    DropdownMenuItem(value: 'Iso', child: Text('Iso')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _mealSize = value;
                    });
                  },
                ),
              if (_mealSizeType == 'Määrä')
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Kpl'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Anna määrä';
                    }

                    final number = int.tryParse(value);

                    if (number == null || number <= 0) {
                      return 'Anna määrä positiivisena lukuna';
                    }

                    return null;
                  },
                ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    saveMeal();
                  }
                },
                child: const Text('Tallenna'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
