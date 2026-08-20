import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kalorilaskuri/db/firestore_util.dart';
import 'package:kalorilaskuri/db/meal.dart';
import 'package:kalorilaskuri/db/sqflite_util.dart';
import 'package:kalorilaskuri/utils/extensions.dart';
import 'package:kalorilaskuri/widgets/add_extra_button.dart';
import 'package:kalorilaskuri/widgets/add_extra_dialog.dart';
import 'package:kalorilaskuri/widgets/extras_list.dart';

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
  // ignore: prefer_final_fields
  List<Meal> _extras = [];
  Meal? _drink;

  @override
  void initState() {
    _datetime = DateTime.now();
    _caloriesController.addListener(() {
      setState(() {});
    });
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

    // Add drink to extras for saving
    if (_drink != null) _extras.add(_drink!);

    try {
      final mealId = await saveMealToDatabase(meal);

      for (final extra in _extras) {
        extra.parentMealId = mealId;
        extra.createdAt = date.toIso8601String(); // Set date to selected date

        await saveMealToDatabase(extra);
      }
    } catch (e) {
      print(e);
      return;
    }

    if (!mounted) return;
    Navigator.pop(context);
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
        title: Text('Uusi ateria'),
        backgroundColor: context.surface,
      ),
      backgroundColor: context.surfaceTrans,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Aterian nimi',
                    ),
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
                  SizedBox(
                    width: double.infinity,
                    child: Text('Lisukkeet:', textAlign: TextAlign.left),
                  ),
                  if (_extras.isNotEmpty)
                    ExtrasList(
                      extras: _extras,
                      onDelete: (extra) {
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
                    child: const Text('Tallenna'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
