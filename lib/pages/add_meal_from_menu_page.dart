import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kalorilaskuri/db/firestore_util.dart';
import 'package:kalorilaskuri/db/food.dart';
import 'package:kalorilaskuri/db/meal.dart';
import 'package:kalorilaskuri/db/sqflite_util.dart';
import 'package:kalorilaskuri/utils/extensions.dart';
import 'package:kalorilaskuri/widgets/add_extra_button.dart';
import 'package:kalorilaskuri/widgets/add_extra_dialog.dart';
import 'package:kalorilaskuri/widgets/extras_list.dart';
import 'package:kalorilaskuri/widgets/form_calories_section.dart';

class AddMealFromMenuPage extends StatefulWidget {
  final Food food;

  const AddMealFromMenuPage({super.key, required this.food});

  @override
  State<AddMealFromMenuPage> createState() => _AddMealFromMenuPageState();
}

class _AddMealFromMenuPageState extends State<AddMealFromMenuPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _weightController = TextEditingController();

  String? _mealSizeType;
  DateTime? _datetime;
  List<Meal> extras = [];
  Meal? drink;
  bool mealSizeTypeEnabled = false;

  @override
  void initState() {
    _amountController.addListener(() {
      setState(() {});
    });
    _weightController.addListener(() {
      setState(() {});
    });
    _datetime = DateTime.now();
    _mealSizeType = widget.food.primarySizeType;
    super.initState();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> saveMeal() async {
    final name = widget.food.name;
    final type = widget.food.type;

    DateTime date = DateTime.now();
    int? weight = _mealSizeType!.getPossibleWeight(_weightController);
    int? amount = _mealSizeType!.getPossibleAmount(_amountController);
    int calories = widget.food.calculateCalories(
      _mealSizeType!,
      _amountController,
      _weightController,
    );
    String? size = _mealSizeType!.getMealSize;

    if (!isSameDate(date, _datetime!)) {
      date = _datetime!;
    }

    final Meal meal = Meal(
      name: name,
      calories: calories,
      type: type,
      weight: weight,
      size: size,
      amount: amount,
      createdAt: date.toIso8601String(),
      fromMenu: 1,
    );

    // Add drink to extras for saving
    if (drink != null) extras.add(drink!);

    try {
      final mealId = await saveMealToDatabase(meal);

      for (final extra in extras) {
        extra.parentMealId = mealId;
        extra.createdAt = date.toIso8601String(); // Set date to selected date

        await saveMealToDatabase(extra);
      }
    } catch (e) {
      print(e);
      return;
    }

    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  int calculateTotalCalories() {
    int calories = widget.food.calculateCalories(
      _mealSizeType!,
      _amountController,
      _weightController,
    );

    calories += extras.totalCalories;

    if (drink != null) calories += drink!.calories;

    return calories;
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
        extras.add(extra);
      });
    } else {
      setState(() {
        drink = extra;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uusi ateria listalta'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsGeometry.all(20),
          child: Column(
            children: [
              Center(
                child: Text(widget.food.name, style: TextStyle(fontSize: 28)),
              ),
              SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  children: [
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
                    FormCaloriesSection(
                      food: widget.food,
                      mealSizeType: _mealSizeType,
                      weightController: _weightController,
                      amountController: _amountController,
                      onChanged: (value) {
                        setState(() {
                          _mealSizeType = value;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: Text('Lisukkeet:', textAlign: TextAlign.left),
                    ),
                    if (extras.isNotEmpty)
                      ExtrasList(
                        extras: extras,
                        onDelete: (extra) {
                          setState(() {
                            extras.remove(extra);
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
                    if (drink != null)
                      ExtrasList(
                        extras: [drink!],
                        onDelete: (extra) {
                          setState(() {
                            drink = null;
                          });
                        },
                      ),
                    if (drink == null)
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
            ],
          ),
        ),
      ),
    );
  }
}
