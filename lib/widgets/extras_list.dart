import 'package:flutter/material.dart';
import 'package:kalorilaskuri/db/meal.dart';

class ExtrasList extends StatelessWidget {
  final List<Meal> extras;
  final ValueChanged<Meal> onDelete;

  const ExtrasList({super.key, required this.extras, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: extras.map((extra) {
        return Card(
          child: ListTile(
            title: Text(extra.name),
            subtitle: Text('${extra.calories} kcal'),
            trailing: IconButton(
              onPressed: () => onDelete(extra),
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
          ),
        );
      }).toList(),
    );
  }
}
