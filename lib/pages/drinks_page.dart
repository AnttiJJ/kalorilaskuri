import 'package:flutter/material.dart';
import 'package:kalorilaskuri/pages/add_drink_page.dart';
import 'package:kalorilaskuri/widgets/foods_stream_builder.dart';

class DrinksPage extends StatefulWidget {
  const DrinksPage({super.key});

  @override
  State<DrinksPage> createState() => _DrinksPageState();
}

class _DrinksPageState extends State<DrinksPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Juomat'),
      ),
      body: FoodsStreamBuilder(type: 'Juoma'),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddDrinkPage()),
          );
          setState(() {});
        },
        tooltip: 'Lisää juoma',
        child: const Icon(Icons.add),
      ),
    );
  }
}
