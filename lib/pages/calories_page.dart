import 'package:flutter/material.dart';

class CaloriesPage extends StatelessWidget {
  const CaloriesPage({super.key});

  void _addCalories() {}

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
        body: const TabBarView(
          children: <Widget>[
            Center(child: Text('Päivä')),
            Center(child: Text('Viikko')),
            Center(child: Text('Kuukausi')),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addCalories,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
