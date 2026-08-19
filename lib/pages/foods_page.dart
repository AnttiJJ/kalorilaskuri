import 'package:flutter/material.dart';
import 'package:kalorilaskuri/pages/add_food_page.dart';
import 'package:kalorilaskuri/widgets/foods_stream_builder.dart';

class FoodsPage extends StatefulWidget {
  const FoodsPage({super.key});

  @override
  State<FoodsPage> createState() => _FoodsPageState();
}

class _FoodsPageState extends State<FoodsPage> {
  final mealsKey = GlobalKey<FoodsStreamBuilderState>();
  final snacksKey = GlobalKey<FoodsStreamBuilderState>();
  final treatsKey = GlobalKey<FoodsStreamBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Ruokalista'),
      ),
      body: SafeArea(
        child: DefaultTabController(
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
            body: TabBarView(
              children: <Widget>[
                FoodsStreamBuilder(key: mealsKey, type: 'Ateria'),
                FoodsStreamBuilder(key: snacksKey, type: 'Välipala'),
                FoodsStreamBuilder(key: treatsKey, type: 'Herkku'),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                final type = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddFoodPage()),
                );

                if (type != null) {
                  switch (type) {
                    case 'Ateria':
                      await mealsKey.currentState?.loadFoodsFresh();
                      break;
                    case 'Välipala':
                      await snacksKey.currentState?.loadFoodsFresh();
                      break;
                    case 'Herkku':
                      await treatsKey.currentState?.loadFoodsFresh();
                      break;
                    default:
                  }
                }
              },
              tooltip: 'Lisää ruoka',
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ),
    );
  }
}
