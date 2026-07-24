import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kalorilaskuri/db/firestore_util.dart';
import 'package:kalorilaskuri/db/food.dart';
import 'package:kalorilaskuri/db/meal.dart';
import 'package:kalorilaskuri/db/sqflite_util.dart';
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

  @override
  void initState() {
    _datetime = DateTime.now();
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
    int calories = 0;
    int? weight;
    int? amount;
    String? size;

    if (!isSameDate(date, _datetime!)) {
      date = _datetime!;
    }

    switch (_mealSizeType) {
      case 'Paino':
        weight = int.parse(_weightController.text);
        calories = weight * widget.food.caloriesPer100g! ~/ 100;
        break;
      case 'Määrä':
        amount = int.parse(_amountController.text);
        calories = amount * widget.food.caloriesPerPiece!;
        break;
      case 'Pieni':
        size = 'Pieni';
        calories = widget.food.caloriesPerSize!['Pieni']!;
        break;
      case 'Normaali':
        size = 'Normaali';
        calories = widget.food.caloriesPerSize!['Normaali']!;
        break;
      case 'Iso':
        size = 'Iso';
        calories = widget.food.caloriesPerSize!['Iso']!;
        break;
      default:
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
        extra.createdAt = date
            .toIso8601String(); // Set date to be same as parent meals

        await saveMealToDatabase(extra);
      }
    } catch (e) {
      print(e);
      return;
    }

    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
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

    // if (!mounted) return;
    // Navigator.of(context).popUntil((route) => route.isFirst);
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
                    // if (widget.food.caloriesPer100g != null)
                    //   Column(
                    //     children: [
                    //       Center(
                    //         child: Text(
                    //           '${widget.food.caloriesPer100g!.toString()} kcal/100g',
                    //           style: _mealSizeType != 'Paino'
                    //               ? TextStyle(color: Colors.grey)
                    //               : null,
                    //         ),
                    //       ),
                    //       Row(
                    //         children: [
                    //           Expanded(
                    //             child: SwitchListTile(
                    //               title: const Text('Paino'),
                    //               value: _mealSizeType == 'Paino',
                    //               onChanged: (value) {
                    //                 setState(() {
                    //                   _mealSizeType = 'Paino';
                    //                 });
                    //               },
                    //             ),
                    //           ),
                    //           Expanded(
                    //             child: TextFormField(
                    //               controller: _weightController,
                    //               keyboardType: TextInputType.number,
                    //               inputFormatters: [
                    //                 FilteringTextInputFormatter.digitsOnly,
                    //               ],
                    //               enabled: _mealSizeType == 'Paino',
                    //               decoration: const InputDecoration(
                    //                 labelText: 'g',
                    //               ),
                    //               validator: (value) {
                    //                 if (_mealSizeType != 'Paino') {
                    //                   return null;
                    //                 }

                    //                 if (value == null || value.isEmpty) {
                    //                   return 'Anna paino';
                    //                 }

                    //                 final number = int.tryParse(value);

                    //                 if (number == null || number <= 0) {
                    //                   return 'Anna paino positiivisena lukuna';
                    //                 }

                    //                 return null;
                    //               },
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ],
                    //   ),
                    // SizedBox(height: 20),
                    // if (widget.food.caloriesPerPiece != null)
                    //   Column(
                    //     children: [
                    //       Center(
                    //         child: Text(
                    //           '${widget.food.caloriesPerPiece!.toString()} kcal/kpl',
                    //           style: _mealSizeType != 'Määrä'
                    //               ? TextStyle(color: Colors.grey)
                    //               : null,
                    //         ),
                    //       ),
                    //       Row(
                    //         children: [
                    //           Expanded(
                    //             child: SwitchListTile(
                    //               title: const Text('Määrä'),
                    //               value: _mealSizeType == 'Määrä',
                    //               onChanged: (value) {
                    //                 setState(() {
                    //                   _mealSizeType = 'Määrä';
                    //                 });
                    //               },
                    //             ),
                    //           ),
                    //           Expanded(
                    //             child: TextFormField(
                    //               controller: _amountController,
                    //               keyboardType: TextInputType.number,
                    //               inputFormatters: [
                    //                 FilteringTextInputFormatter.digitsOnly,
                    //               ],
                    //               enabled: _mealSizeType == 'Määrä',
                    //               decoration: const InputDecoration(
                    //                 labelText: 'kpl',
                    //               ),
                    //               validator: (value) {
                    //                 if (_mealSizeType != 'Määrä') {
                    //                   return null;
                    //                 }

                    //                 if (value == null || value.isEmpty) {
                    //                   return 'Anna määrä';
                    //                 }

                    //                 final number = int.tryParse(value);

                    //                 if (number == null || number <= 0) {
                    //                   return 'Anna määrä positiivisena lukuna';
                    //                 }

                    //                 return null;
                    //               },
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ],
                    //   ),
                    // SizedBox(height: 30),
                    // if (widget.food.caloriesPerSize != null)
                    //   Column(
                    //     children: [
                    //       Text('Annokset', style: TextStyle(fontSize: 20)),
                    //       SizedBox(height: 20),
                    //       SegmentedButton(
                    //         segments: [
                    //           ButtonSegment(
                    //             value: 'Pieni',
                    //             enabled:
                    //                 widget.food.caloriesPerSize!['Pieni'] != null,
                    //             label: const Text('Pieni'),
                    //           ),
                    //           ButtonSegment(
                    //             value: 'Normaali',
                    //             enabled:
                    //                 widget.food.caloriesPerSize!['Normaali'] !=
                    //                 null,
                    //             label: const Text('Normaali'),
                    //           ),
                    //           ButtonSegment(
                    //             value: 'Iso',
                    //             enabled:
                    //                 widget.food.caloriesPerSize!['Iso'] != null,
                    //             label: const Text('Iso'),
                    //           ),
                    //         ],
                    //         selected: {_mealSizeType},
                    //         onSelectionChanged: (selection) {
                    //           setState(() {
                    //             _mealSizeType = selection.first;
                    //           });
                    //         },
                    //       ),
                    //     ],
                    //   ),
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
          ),
        ),
      ),
    );
  }
}
