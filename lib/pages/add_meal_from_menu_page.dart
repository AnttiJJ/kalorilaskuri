import 'package:flutter/material.dart';
import 'package:kalorilaskuri/db/food.dart';

class AddMealFromMenuPage extends StatefulWidget {
  final Food food;

  const AddMealFromMenuPage({super.key, required this.food});

  @override
  State<AddMealFromMenuPage> createState() => _AddMealFromMenuPageState();
}

class _AddMealFromMenuPageState extends State<AddMealFromMenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uusi ateria listalta'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(child: Text(widget.food.name)),
    );
  }
}
