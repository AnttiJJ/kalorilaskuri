import 'package:flutter/material.dart';
import 'package:kalorilaskuri/pages/add_extra_page.dart';
import 'package:kalorilaskuri/widgets/foods_stream_builder.dart';

class ExtrasPage extends StatefulWidget {
  const ExtrasPage({super.key});

  @override
  State<ExtrasPage> createState() => _ExtrasPageState();
}

class _ExtrasPageState extends State<ExtrasPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Lisukkeet'),
      ),
      body: FoodsStreamBuilder(type: 'Lisuke'),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExtraPage()),
          );
          setState(() {});
        },
        tooltip: 'Lisää lisuke',
        child: const Icon(Icons.add),
      ),
    );
  }
}
