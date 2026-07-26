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

class UpdateMealFromMenuPage extends StatefulWidget {
  final Meal meal;
  final List<Meal> extras;
  final Meal? drink;

  const UpdateMealFromMenuPage({
    super.key,
    required this.meal,
    required this.extras,
    required this.drink,
  });

  @override
  State<UpdateMealFromMenuPage> createState() => _UpdateMealFromMenuPageState();
}

class _UpdateMealFromMenuPageState extends State<UpdateMealFromMenuPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _weightController = TextEditingController();

  Food? _food;
  String? _mealSizeType;
  bool loading = true;
  List<Meal> _extras = [];
  Meal? _drink;
  List<Meal> _deletedExtras = [];

  @override
  void initState() {
    _amountController.addListener(() {
      setState(() {});
    });
    _weightController.addListener(() {
      setState(() {});
    });

    if (widget.meal.size != null) {
      _mealSizeType = widget.meal.size;
    } else if (widget.meal.amount != null) {
      _mealSizeType = 'Määrä';
      _amountController.text = widget.meal.amount.toString();
    } else {
      _mealSizeType = 'Paino';
      _weightController.text = widget.meal.weight.toString();
    }

    _extras = widget.extras;
    _drink = widget.drink;

    loadFood();

    super.initState();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> loadFood() async {
    try {
      final FirestoreUtil firestoreUtil = FirestoreUtil();
      _food = await firestoreUtil.getFood(widget.meal.name);
    } catch (e) {
      print(e);
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> saveMeal() async {
    final name = _food!.name;
    final type = _food!.type;
    final date = widget.meal.createdAt;

    int? weight = _mealSizeType!.getPossibleWeight(_weightController);
    int? amount = _mealSizeType!.getPossibleAmount(_amountController);
    int calories = _food!.calculateCalories(
      _mealSizeType!,
      _amountController,
      _weightController,
    );
    String? size = _mealSizeType!.getMealSize;

    final Meal updatedMeal = Meal(
      id: widget.meal.id,
      name: name,
      calories: calories,
      type: type,
      weight: weight,
      size: size,
      amount: amount,
      createdAt: date,
      fromMenu: 1,
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

  int calculateTotalCalories() {
    int calories = _food!.calculateCalories(
      _mealSizeType!,
      _amountController,
      _weightController,
    );

    calories += _extras.totalCalories;

    if (_drink != null) calories += _drink!.calories;

    return calories;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Muokkaa ateriaa'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsGeometry.all(20),
          child: Column(
            children: [
              if (loading)
                const CircularProgressIndicator()
              else ...[
                Center(
                  child: Text(_food!.name, style: TextStyle(fontSize: 28)),
                ),
                SizedBox(height: 30),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      FormCaloriesSection(
                        food: _food!,
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
                        child: const Text('Tallenna'),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
