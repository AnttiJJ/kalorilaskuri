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

  //List<Meal>? meals;
  DateTime date = DateTime.now();
  bool loading = true;

  @override
  void initState() {
    //loadMeals();
    super.initState();
  }

  Future<void> loadMeals() async {
    final SqfliteUtil sqfliteUtil = SqfliteUtil();

    //meals = await sqfliteUtil.getMeals();
    setState(() {
      loading = false;
    });
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
          //if (loading) const Center(child: CircularProgressIndicator()),
          //if (!loading && meals == null)
          //const Center(child: Text('Ei aterioita')),
          //if (!loading && meals != null)
          // ListView.builder(
          //   itemCount: meals!.length,
          //   itemBuilder: (context, index) {
          //     return ListTile(title: Text(meals![index].name));
          //   },
          // ),
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
                    return ListTile(title: Text(meals[index].name));
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMealPage()),
          );
        },
        tooltip: 'Lisää ateria',
        child: const Icon(Icons.add),
      ),
    );
  }
}
