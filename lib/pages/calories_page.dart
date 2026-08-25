import 'package:flutter/material.dart';
import 'package:kalorilaskuri/db/firestore_util.dart';
import 'package:kalorilaskuri/widgets/add_calories_dialog.dart';
import 'package:kalorilaskuri/widgets/calories_daily_widget.dart';

class CaloriesPage extends StatefulWidget {
  const CaloriesPage({super.key});

  @override
  State<CaloriesPage> createState() => _CaloriesPageState();
}

class _CaloriesPageState extends State<CaloriesPage> {
  Future<void> _addCalories(int calories, DateTime datetime) async {
    try {
      final FirestoreUtil firestoreUtil = FirestoreUtil();
      await firestoreUtil.addCalories(calories, 'Kulutettu', datetime);

      if (!mounted) return;
    } catch (e) {
      print(e);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const TabBar(
            tabs: <Widget>[
              Tab(text: 'Päivä'),
              Tab(text: 'Viikko'),
              Tab(text: 'Kuukausi'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            CaloriesDailyWidget(),
            Center(child: Text('Viikko')),
            Center(child: Text('Kuukausi')),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await showDialog<Map<String, dynamic>>(
              context: context,
              builder: (_) => const AddCaloriesDialog(),
            );

            if (result != null) {
              final calories = result['calories'] as int;
              final date = result['date'] as DateTime;

              await _addCalories(calories, date);
            }
          },
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
