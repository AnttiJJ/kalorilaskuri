import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kalorilaskuri/db/firestore_util.dart';
import 'package:kalorilaskuri/db/meal.dart';
import 'package:kalorilaskuri/db/sqflite_util.dart';
import 'package:kalorilaskuri/utils/extensions.dart';
import 'package:kalorilaskuri/widgets/add_extra_button.dart';
import 'package:kalorilaskuri/widgets/add_extra_dialog.dart';
import 'package:kalorilaskuri/widgets/extras_list.dart';

class UpdateMealPage extends StatefulWidget {
  final Meal meal;
  final List<Meal> extras;
  final Meal? drink;

  const UpdateMealPage({
    super.key,
    required this.meal,
    required this.extras,
    required this.drink,
  });

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
  List<Meal> _extras = [];
  Meal? _drink;
  // ignore: prefer_final_fields
  List<Meal> _deletedExtras = [];

  @override
  void initState() {
    _nameController.text = widget.meal.name;
    _caloriesController.text = widget.meal.calories.toString();
    _caloriesController.addListener(() {
      setState(() {});
    });

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

    _extras = widget.extras;
    _drink = widget.drink;

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
    final weight = _mealSizeType.getPossibleWeight(_weightController);
    final amount = _mealSizeType.getPossibleAmount(_amountController);
    final size = _mealSizeType == 'Koko' ? _mealSize : null;
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

    // Add drink to extras for saving
    if (_drink != null) _extras.add(_drink!);

    try {
      await updateMeal(updatedMeal);

      for (final extra in _extras) {
        // if old extra -> update, else add to database
        if (extra.id != null) {
          continue;
        }
        extra.parentMealId = updatedMeal.id;
        extra.createdAt = date;

        await saveMealToDatabase(extra);
      }

      for (final extra in _deletedExtras) {
        await deleteMeal(
          extra.id!,
          extra.calories,
          extra.type,
          DateTime.parse(date),
        );
      }
    } catch (e) {
      print(e);
      return;
    }

    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> updateMeal(Meal meal) async {
    final FirestoreUtil firestoreUtil = FirestoreUtil();
    await firestoreUtil.updateCalories(
      meal.calories - widget.meal.calories,
      meal.type,
      DateTime.parse(meal.createdAt),
    );

    final SqfliteUtil sqfliteUtil = SqfliteUtil();
    await sqfliteUtil.updateMeal(meal);
  }

  Future<int> saveMealToDatabase(Meal meal) async {
    final FirestoreUtil firestoreUtil = FirestoreUtil();
    await firestoreUtil.addCalories(
      meal.calories,
      meal.type,
      DateTime.parse(meal.createdAt),
    );

    final SqfliteUtil sqfliteUtil = SqfliteUtil();
    return await sqfliteUtil.insertMeal(meal);
  }

  Future<void> deleteMeal(
    int id,
    int calories,
    String type,
    DateTime datetime,
  ) async {
    final SqfliteUtil sqfliteUtil = SqfliteUtil();
    await sqfliteUtil.deleteMeal(id, calories, type, datetime);
  }

  Future<void> showExtraDialog(String type) async {
    Meal? extra = await showDialog<Meal?>(
      context: context,
      builder: (_) => AddExtraDialog(type: type),
    );

    if (extra == null) return;

    if (extra.type == 'Lisuke') {
      setState(() {
        _extras.add(extra);
      });
    } else {
      setState(() {
        _drink = extra;
      });
    }
  }

  int calculateTotalCalories() {
    int calories = 0;
    if (_caloriesController.text.isNotEmpty) {
      calories += int.parse(_caloriesController.text);
    }

    calories += _extras.totalCalories;

    if (_drink != null) calories += _drink!.calories;

    return calories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Muokkaa ateriaa'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                    decoration: const InputDecoration(
                      labelText: 'Aterian koko',
                    ),
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
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: Text('Lisukkeet:', textAlign: TextAlign.left),
                ),
                if (_extras.isNotEmpty)
                  ExtrasList(
                    extras: _extras,
                    onDelete: (extra) {
                      if (extra.id != null) _deletedExtras.add(extra);
                      setState(() {
                        _extras.remove(extra);
                      });
                    },
                  ),
                AddExtraButton(
                  onPressed: () async {
                    showExtraDialog('Lisuke');
                  },
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: Text('Juoma:', textAlign: TextAlign.left),
                ),
                if (_drink != null)
                  ExtrasList(
                    extras: [_drink!],
                    onDelete: (extra) {
                      if (extra.id != null) _deletedExtras.add(extra);
                      setState(() {
                        _drink = null;
                      });
                    },
                  ),
                if (_drink == null)
                  AddExtraButton(
                    onPressed: () async {
                      showExtraDialog('Juoma');
                    },
                  ),
                SizedBox(height: 20),
                Text('Kalorit:'),
                Text(
                  calculateTotalCalories().toString(),
                  style: TextStyle(fontSize: 26),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      saveMeal();
                    }
                  },
                  child: const Text('Päivitä'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
