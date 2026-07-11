import 'package:flutter/material.dart';
import 'package:kalorilaskuri/db/daily_calories.dart';
import 'package:kalorilaskuri/db/firestore_util.dart';
import 'package:kalorilaskuri/widgets/date_bar.dart';

class CaloriesDailyWidget extends StatefulWidget {
  const CaloriesDailyWidget({super.key});

  @override
  State<CaloriesDailyWidget> createState() => CaloriesDailyWidgetState();
}

class CaloriesDailyWidgetState extends State<CaloriesDailyWidget> {
  final FirestoreUtil firestoreUtil = FirestoreUtil();

  DateTime _date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DateBar(
          onDateChanged: (newDate) {
            setState(() {
              _date = newDate;
            });
          },
        ),
        SizedBox(height: 20),
        Expanded(
          child: FutureBuilder<DailyCalories?>(
            future: firestoreUtil.getCaloriesDay(_date),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData) {
                return const Center(child: Text('Ei merkattuja kaloreita'));
              }

              final DailyCalories calories = snapshot.data!;

              return Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Calories',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Divider(),

                      _row('Ateriat', calories.meals),
                      _row('Välipalat', calories.snacks),
                      _row('Herkut', calories.sweets),
                      _row('Lisukkeet', calories.extras),
                      _row('Juomat', calories.drinks),

                      const Divider(),

                      _row('Saadut', calories.consumed()),
                      _row('Kulutettu', calories.used),

                      const Divider(),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                calories.difference().toString(),
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  color: calories.difference() <= 0
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _row(String title, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          Text('$value kcal'),
        ],
      ),
    );
  }
}
