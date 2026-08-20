import 'package:flutter/material.dart';
import 'package:kalorilaskuri/pages/add_drink_page.dart';
import 'package:kalorilaskuri/widgets/foods_stream_builder.dart';

class DrinksPage extends StatefulWidget {
  const DrinksPage({super.key});

  @override
  State<DrinksPage> createState() => _DrinksPageState();
}

class _DrinksPageState extends State<DrinksPage> {
  final drinksKey = GlobalKey<FoodsStreamBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Juomat')),
      body: FoodsStreamBuilder(key: drinksKey, type: 'Juoma'),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddDrinkPage()),
          );

          if (added != null) {
            if (added) {
              await drinksKey.currentState?.loadFoodsFresh();
            }
          }
        },
        tooltip: 'Lisää juoma',
        child: const Icon(Icons.add),
      ),
    );
  }
}
