import 'package:flutter/material.dart';
import 'package:kalorilaskuri/db/meal.dart';
import 'package:kalorilaskuri/db/sqflite_util.dart';
import 'package:kalorilaskuri/pages/add_meal_page.dart';
import 'package:kalorilaskuri/utils/extensions.dart';

class MealsPage extends StatefulWidget {
  const MealsPage({super.key});

  @override
  State<MealsPage> createState() => _MealsPageState();
}

class _MealsPageState extends State<MealsPage> {
  final SqfliteUtil sqfliteUtil = SqfliteUtil();

  DateTime date = DateTime.now();
  bool loading = true;

  @override
  void initState() {
    super.initState();
  }

  Future<void> loadMeals() async {
    final SqfliteUtil sqfliteUtil = SqfliteUtil();
    setState(() {
      loading = false;
    });
  }

  Future<void> deleteMeal(int id, String name) async {
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
        await sqfliteUtil.deleteMeal(id);
        setState(() {});
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2026, 6, 1),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        date = selectedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    date = date.subtract(const Duration(days: 1));
                  });
                },
                icon: Icon(Icons.arrow_left),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      _selectDate();
                    },
                    icon: Icon(Icons.calendar_month),
                  ),
                  Text(date.formatDate),
                ],
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    date = date.add(const Duration(days: 1));
                  });
                },
                icon: Icon(Icons.arrow_right),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder<List<Meal>>(
              future: sqfliteUtil.getMeals(),
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
                        trailing: IconButton(
                          onPressed: () =>
                              deleteMeal(meals[index].id!, meals[index].name),
                          icon: Icon(Icons.delete, color: Colors.red),
                        ),
                        subtitle: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Kalorit: ${meals[index].calories.toString()}',
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
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMealPage()),
          );
          setState(() {});
        },
        tooltip: 'Lisää ateria',
        child: const Icon(Icons.add),
      ),
    );
  }
}
