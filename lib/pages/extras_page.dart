import 'package:flutter/material.dart';
import 'package:kalorilaskuri/pages/add_extra_page.dart';
import 'package:kalorilaskuri/widgets/foods_stream_builder.dart';

class ExtrasPage extends StatefulWidget {
  const ExtrasPage({super.key});

  @override
  State<ExtrasPage> createState() => _ExtrasPageState();
}

class _ExtrasPageState extends State<ExtrasPage> {
  final extrasKey = GlobalKey<FoodsStreamBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lisukkeet')),
      body: FoodsStreamBuilder(key: extrasKey, type: 'Lisuke'),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExtraPage()),
          );
          if (added != null) {
            if (added) {
              await extrasKey.currentState?.loadFoodsFresh();
            }
          }
        },
        tooltip: 'Lisää lisuke',
        child: const Icon(Icons.add),
      ),
    );
  }
}
