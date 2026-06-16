import 'package:flutter/material.dart';
import 'package:kalorilaskuri/pages/add_food_page.dart';

class FoodsPage extends StatefulWidget {
  const FoodsPage({super.key});

  @override
  State<FoodsPage> createState() => _FoodsPageState();
}

class _FoodsPageState extends State<FoodsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Ruokalista'),
      ),
      body: DefaultTabController(
        initialIndex: 0,
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const TabBar(
              tabs: <Widget>[
                Tab(text: 'Ateriat'),
                Tab(text: 'Välipalat'),
                Tab(text: 'Herkut'),
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
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddFoodPage()),
              );
              setState(() {});
            },
            tooltip: 'Lisää ruoka',
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
