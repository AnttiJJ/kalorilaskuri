import 'package:flutter/material.dart';
import 'package:kalorilaskuri/db/meal.dart';
import 'package:kalorilaskuri/db/sqflite_util.dart';
import 'package:kalorilaskuri/pages/select_meal_from_menu_page.dart';
import 'package:kalorilaskuri/pages/add_meal_page.dart';
import 'package:kalorilaskuri/pages/update_meal_from_menu_page.dart';
import 'package:kalorilaskuri/pages/update_meal_page.dart';
import 'package:kalorilaskuri/utils/extensions.dart';
import 'package:kalorilaskuri/widgets/date_bar.dart';

class MealsPage extends StatefulWidget {
  const MealsPage({super.key});

  @override
  State<MealsPage> createState() => _MealsPageState();
}

class _MealsPageState extends State<MealsPage> {
  final SqfliteUtil sqfliteUtil = SqfliteUtil();

  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  Future<void> deleteMeal(
    int id,
    String name,
    int calories,
    String type,
    DateTime datetime,
  ) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Poista ateria'),
          content: Text('Haluatko varmasti poistaa $name aterian'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Peruuta'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Poista'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        final SqfliteUtil sqfliteUtil = SqfliteUtil();
        await sqfliteUtil.deleteMeal(id, calories, type, datetime);
        setState(() {});
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> newMealDialog() async {
    bool? fromMenu;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 100,
                width: 250,
                child: FilledButton(
                  onPressed: () {
                    fromMenu = true;
                    Navigator.pop(context);
                  },
                  child: const Text('Listalta', style: TextStyle(fontSize: 34)),
                ),
              ),
              SizedBox(height: 40),
              SizedBox(
                height: 100,
                width: 250,
                child: FilledButton(
                  onPressed: () {
                    fromMenu = false;
                    Navigator.pop(context);
                  },
                  child: const Text('Kustomi', style: TextStyle(fontSize: 34)),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted) return;

    if (fromMenu == false) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddMealPage()),
      );
    } else if (fromMenu == true) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SelectMealFromMenuPage()),
      );
    }
    setState(() {});
  }

  Future<void> _selectDate() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2026, 6, 1),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        _date = selectedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceAround,
          //   children: [
          //     IconButton(
          //       onPressed: () {
          //         setState(() {
          //           _date = _date.subtract(const Duration(days: 1));
          //         });
          //       },
          //       icon: Icon(Icons.arrow_left),
          //     ),
          //     Row(
          //       children: [
          //         IconButton(
          //           onPressed: () {
          //             _selectDate();
          //           },
          //           icon: Icon(Icons.calendar_month),
          //         ),
          //         Text(_date.formatDate),
          //       ],
          //     ),
          //     IconButton(
          //       onPressed: () {
          //         setState(() {
          //           _date = _date.add(const Duration(days: 1));
          //         });
          //       },
          //       icon: Icon(Icons.arrow_right),
          //     ),
          //   ],
          // ),
          DateBar(
            onDateChanged: (newDate) {
              setState(() {
                _date = newDate;
              });
            },
          ),
          Expanded(
            child: FutureBuilder<List<Meal>>(
              future: sqfliteUtil.getMeals(_date),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final meals = snapshot.data!;

                return ListView.builder(
                  itemCount: meals.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text(meals[index].name),
                        leading: meals[index].icon,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      if (meals[index].fromMenu != 1) {
                                        return UpdateMealPage(
                                          meal: meals[index],
                                        );
                                      } else {
                                        return UpdateMealFromMenuPage(
                                          meal: meals[index],
                                        );
                                      }
                                    },
                                  ),
                                );
                                setState(() {});
                              },
                              icon: Icon(Icons.mode, color: Colors.blue),
                            ),
                            IconButton(
                              onPressed: () => deleteMeal(
                                meals[index].id!,
                                meals[index].name,
                                meals[index].calories,
                                meals[index].type,
                                DateTime.parse(meals[index].createdAt),
                              ),
                              icon: Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                        subtitle: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${meals[index].calories.toString()} kcal',
                              ),
                            ),
                            Expanded(child: Text(meals[index].mealSize)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => newMealDialog(),
        tooltip: 'Lisää ateria',
        child: const Icon(Icons.add),
      ),
    );
  }
}
