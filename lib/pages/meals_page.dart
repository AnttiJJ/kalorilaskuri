import 'package:flutter/material.dart';
import 'package:kalorilaskuri/animations/fade_slide_up.dart';
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
  int _expandedMeal = -1;
  List<Meal> parentMeals = [];
  List<Meal> extras = [];
  List<Meal> _mealsExtras = [];
  Meal? _mealsDrink;
  bool deleteInProgress = false;
  double offset = 0;

  @override
  void initState() {
    super.initState();
  }

  Future<void> deleteMealDialog(
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
      setState(() {
        deleteInProgress = true;
      });

      final List<Meal> deleteMealExtras = extras
          .where((extra) => extra.parentMealId == id)
          .toList();

      for (final extra in deleteMealExtras) {
        await deleteMeal(extra.id!, extra.calories, extra.type, datetime);
      }

      await deleteMeal(id, calories, type, datetime);

      setState(() {
        deleteInProgress = false;
      });
    }
  }

  Future<void> deleteMeal(
    int id,
    int calories,
    String type,
    DateTime datetime,
  ) async {
    try {
      final SqfliteUtil sqfliteUtil = SqfliteUtil();
      await sqfliteUtil.deleteMeal(id, calories, type, datetime);
    } catch (e) {
      print(e);
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
    if (!mounted) return;
    setState(() {});
  }

  int totalMealCalories(Meal meal) {
    final List<Meal> mealsExtras = extras
        .where((extra) => extra.parentMealId == meal.id)
        .toList();

    return meal.calories + mealsExtras.totalCalories;
  }

  void setMealsExtras(int expandedMealId) {
    _mealsExtras = [];
    _mealsDrink = null;

    for (final extra in extras) {
      if (extra.parentMealId != expandedMealId) continue;

      if (extra.type == 'Lisuke') {
        _mealsExtras.add(extra);
      } else {
        _mealsDrink = extra;
      }
    }
  }

  Future<void> updateMeal(Meal meal) async {
    setMealsExtras(meal.id!);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          if (meal.fromMenu != 1) {
            return UpdateMealPage(
              meal: meal,
              extras: _mealsExtras,
              drink: _mealsDrink,
            );
          } else {
            return UpdateMealFromMenuPage(
              meal: meal,
              extras: _mealsExtras,
              drink: _mealsDrink,
            );
          }
        },
      ),
    );

    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DateBar(
        onDateChanged: (newDate) {
          setState(() {
            _date = newDate;
          });
        },
        child: FutureBuilder<List<Meal>>(
          future: sqfliteUtil.getMeals(_date),
          builder: (context, snapshot) {
            if (!snapshot.hasData || deleteInProgress) {
              return Center(child: const CircularProgressIndicator());
            }

            final meals = snapshot.data!;
            parentMeals = [];
            extras = [];

            for (final meal in meals) {
              if (meal.parentMealId != null) {
                extras.add(meal);
              } else {
                parentMeals.add(meal);
              }
            }

            return ListView.builder(
              itemCount: parentMeals.length,
              itemBuilder: (context, index) {
                return FadeSlideUp(
                  key: ValueKey(parentMeals[index].id),
                  delay: Duration(milliseconds: index * 150),
                  child: Card(
                    key: ValueKey(parentMeals[index].id),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          setMealsExtras(parentMeals[index].id!);
                          if (_expandedMeal != index) {
                            _expandedMeal = index;
                          } else {
                            _expandedMeal = -1;
                          }
                        });
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text(parentMeals[index].name),
                            leading: parentMeals[index].icon,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    await updateMeal(parentMeals[index]);
                                  },
                                  icon: Icon(Icons.mode, color: Colors.blue),
                                ),
                                IconButton(
                                  onPressed: () => deleteMealDialog(
                                    parentMeals[index].id!,
                                    parentMeals[index].name,
                                    parentMeals[index].calories,
                                    parentMeals[index].type,
                                    DateTime.parse(
                                      parentMeals[index].createdAt,
                                    ),
                                  ),
                                  icon: Icon(Icons.delete, color: Colors.red),
                                ),
                              ],
                            ),
                            subtitle: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    totalMealCalories(parentMeals[index]) !=
                                            parentMeals[index].calories
                                        ? '${totalMealCalories(parentMeals[index])} (${parentMeals[index].calories.toString()}) kcal'
                                        : '${parentMeals[index].calories.toString()} kcal',
                                  ),
                                ),
                                Expanded(
                                  child: Text(parentMeals[index].mealSize),
                                ),
                              ],
                            ),
                          ),
                          if (_expandedMeal == index &&
                              (_mealsExtras.isNotEmpty || _mealsDrink != null))
                            Padding(
                              padding: EdgeInsetsGeometry.fromLTRB(
                                57,
                                0,
                                16,
                                16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_mealsExtras.isNotEmpty)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Lisukkeet:'),
                                        for (final extra in _mealsExtras)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '${extra.name} ${extra.mealSizeShort}',
                                              ),
                                              Text('${extra.calories} kcal'),
                                            ],
                                          ),

                                        SizedBox(height: 5),
                                      ],
                                    ),

                                  if (_mealsDrink != null)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Juoma:'),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${_mealsDrink!.name} ${_mealsDrink!.mealSizeShort}',
                                            ),
                                            Text(
                                              '${_mealsDrink!.calories} kcal',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => newMealDialog(),
        tooltip: 'Lisää ateria',
        child: const Icon(Icons.add),
      ),
    );
  }
}
