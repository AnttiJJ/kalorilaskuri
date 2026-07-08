import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kalorilaskuri/db/firestore_util.dart';
import 'package:kalorilaskuri/db/meal.dart';
import 'package:kalorilaskuri/db/sqflite_util.dart';

class UpdateMealPage extends StatefulWidget {
  const UpdateMealPage({super.key, required this.meal});

  final Meal meal;

  @override
  State<UpdateMealPage> createState() => _UpdateMealPageState();
}

class _UpdateMealPageState extends State<UpdateMealPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _weightController = TextEditingController();
  final _amountController = TextEditingController();

  String _type = 'Ateria';
  String _mealSizeType = 'Paino';
  String? _mealSize;

  @override
  void initState() {
    _nameController.text = widget.meal.name;
    _caloriesController.text = widget.meal.calories.toString();

    _type = widget.meal.type;

    if (widget.meal.size != null) {
      _mealSizeType = 'Koko';
      _mealSize = widget.meal.size;
    } else if (widget.meal.amount != null) {
      _mealSizeType = 'Määrä';
      _amountController.text = widget.meal.amount.toString();
    } else {
      _weightController.text = widget.meal.weight.toString();
    }

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

  Future<void> updateMeal() async {
    final name = _nameController.text;
    final calories = int.parse(_caloriesController.text);
    final weight = _mealSizeType == 'Paino'
        ? int.parse(_weightController.text)
        : null;
    final size = _mealSizeType == 'Koko' ? _mealSize : null;
    final amount = _mealSizeType == 'Määrä'
        ? int.parse(_amountController.text)
        : null;
    final date = widget.meal.createdAt;

    final Meal updatedMeal = Meal(
      id: widget.meal.id,
      name: name,
      calories: calories,
      type: _type,
      weight: weight,
      size: size,
      amount: amount,
      createdAt: date,
      fromMenu: 0,
    );

    try {
      final FirestoreUtil firestoreUtil = FirestoreUtil();
      await firestoreUtil.updateCalories(
        calories - widget.meal.calories,
        _type,
        DateTime.parse(date),
      );

      SqfliteUtil sqfliteUtil = SqfliteUtil();
      await sqfliteUtil.updateMeal(updatedMeal);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      print(e);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Muokkaa ateriaa'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
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
              SegmentedButton(
                segments: const [
                  ButtonSegment(value: 'Ateria', label: Text('Ateria')),
                  ButtonSegment(value: 'Välipala', label: Text('Välipala')),
                  ButtonSegment(value: 'Herkku', label: Text('Herkku')),
                ],
                selected: {_type},
                onSelectionChanged: (selection) {
                  setState(() {
                    _type = selection.first;
                  });
                },
              ),
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
                  initialValue: widget.meal.size,
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
                  decoration: const InputDecoration(labelText: 'Määrä'),
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
                    updateMeal();
                  }
                },
                child: const Text('Päivitä'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
