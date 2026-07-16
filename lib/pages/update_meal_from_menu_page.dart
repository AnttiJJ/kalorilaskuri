import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kalorilaskuri/db/firestore_util.dart';
import 'package:kalorilaskuri/db/food.dart';
import 'package:kalorilaskuri/db/meal.dart';
import 'package:kalorilaskuri/db/sqflite_util.dart';

class UpdateMealFromMenuPage extends StatefulWidget {
  final Meal meal;

  const UpdateMealFromMenuPage({super.key, required this.meal});

  @override
  State<UpdateMealFromMenuPage> createState() => _UpdateMealFromMenuPageState();
}

class _UpdateMealFromMenuPageState extends State<UpdateMealFromMenuPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _weightController = TextEditingController();

  Food? food;
  String? _mealSizeType;
  bool loading = true;

  @override
  void initState() {
    if (widget.meal.size != null) {
      _mealSizeType = widget.meal.size;
    } else if (widget.meal.amount != null) {
      _mealSizeType = 'Määrä';
      _amountController.text = widget.meal.amount.toString();
    } else {
      _mealSizeType = 'Paino';
      _weightController.text = widget.meal.weight.toString();
    }

    loadMeal();

    super.initState();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> loadMeal() async {
    try {
      final FirestoreUtil firestoreUtil = FirestoreUtil();
      food = await firestoreUtil.getFood(widget.meal.name);
    } catch (e) {
      print(e);
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> saveMeal() async {
    final name = food!.name;
    final type = food!.type;
    final date = widget.meal.createdAt;

    int calories = 0;
    int? weight;
    int? amount;
    String? size;

    switch (_mealSizeType) {
      case 'Paino':
        weight = int.parse(_weightController.text);
        calories = weight * food!.caloriesPer100g! ~/ 100;
        break;
      case 'Määrä':
        amount = int.parse(_amountController.text);
        calories = amount * food!.caloriesPerPiece!;
        break;
      case 'Pieni':
        size = 'Pieni';
        calories = food!.caloriesPerSize!['Pieni']!;
        break;
      case 'Normaali':
        size = 'Normaali';
        calories = food!.caloriesPerSize!['Normaali']!;
        break;
      case 'Iso':
        size = 'Iso';
        calories = food!.caloriesPerSize!['Iso']!;
        break;
      default:
    }

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

    print(updatedMeal.id);

    try {
      final FirestoreUtil firestoreUtil = FirestoreUtil();
      await firestoreUtil.updateCalories(
        calories - widget.meal.calories,
        type,
        DateTime.parse(date),
      );

      final SqfliteUtil sqfliteUtil = SqfliteUtil();
      await sqfliteUtil.updateMeal(updatedMeal);

      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      print(e);
      return;
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
                Center(child: Text(food!.name, style: TextStyle(fontSize: 28))),
                SizedBox(height: 30),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (food!.caloriesPer100g != null)
                        Column(
                          children: [
                            Center(
                              child: Text(
                                '${food!.caloriesPer100g!.toString()} kcal/100g',
                                style: _mealSizeType != 'Paino'
                                    ? TextStyle(color: Colors.grey)
                                    : null,
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: SwitchListTile(
                                    title: const Text('Paino'),
                                    value: _mealSizeType == 'Paino',
                                    onChanged: (value) {
                                      setState(() {
                                        _mealSizeType = 'Paino';
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: TextFormField(
                                    controller: _weightController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    enabled: _mealSizeType == 'Paino',
                                    decoration: const InputDecoration(
                                      labelText: 'g',
                                    ),
                                    validator: (value) {
                                      if (_mealSizeType != 'Paino') {
                                        return null;
                                      }

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
                                ),
                              ],
                            ),
                          ],
                        ),
                      SizedBox(height: 20),
                      if (food!.caloriesPerPiece != null)
                        Column(
                          children: [
                            Center(
                              child: Text(
                                '${food!.caloriesPerPiece!.toString()} kcal/kpl',
                                style: _mealSizeType != 'Määrä'
                                    ? TextStyle(color: Colors.grey)
                                    : null,
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: SwitchListTile(
                                    title: const Text('Määrä'),
                                    value: _mealSizeType == 'Määrä',
                                    onChanged: (value) {
                                      setState(() {
                                        _mealSizeType = 'Määrä';
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: TextFormField(
                                    controller: _amountController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    enabled: _mealSizeType == 'Määrä',
                                    decoration: const InputDecoration(
                                      labelText: 'kpl',
                                    ),
                                    validator: (value) {
                                      if (_mealSizeType != 'Määrä') {
                                        return null;
                                      }

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
                                ),
                              ],
                            ),
                          ],
                        ),
                      SizedBox(height: 30),
                      if (food!.caloriesPerSize != null)
                        Column(
                          children: [
                            Text('Annokset', style: TextStyle(fontSize: 20)),
                            SizedBox(height: 20),
                            SegmentedButton(
                              segments: [
                                ButtonSegment(
                                  value: 'Pieni',
                                  enabled:
                                      food!.caloriesPerSize!['Pieni'] != null,
                                  label: const Text('Pieni'),
                                ),
                                ButtonSegment(
                                  value: 'Normaali',
                                  enabled:
                                      food!.caloriesPerSize!['Normaali'] !=
                                      null,
                                  label: const Text('Normaali'),
                                ),
                                ButtonSegment(
                                  value: 'Iso',
                                  enabled:
                                      food!.caloriesPerSize!['Iso'] != null,
                                  label: const Text('Iso'),
                                ),
                              ],
                              selected: {_mealSizeType},
                              onSelectionChanged: (selection) {
                                setState(() {
                                  _mealSizeType = selection.first;
                                });
                              },
                            ),
                          ],
                        ),
                      SizedBox(height: 50),
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
