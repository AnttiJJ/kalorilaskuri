import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kalorilaskuri/db/food.dart';
import 'package:kalorilaskuri/pages/add_meal_from_menu_page.dart';

class SelectMealFromMenuPage extends StatefulWidget {
  const SelectMealFromMenuPage({super.key});

  @override
  State<SelectMealFromMenuPage> createState() => _AddMealFromMenuPageState();
}

class _AddMealFromMenuPageState extends State<SelectMealFromMenuPage> {
  final int pageSize = 5;

  String _type = 'Ateria';
  DocumentSnapshot<Map<String, dynamic>>? lastDoc;
  List<Food> foods = [];
  String _searchText = '';

  @override
  void initState() {
    loadFoods();
    super.initState();
  }

  void loadFoodsFresh() {
    foods = [];
    loadFoods();
  }

  Future<void> loadFoods({bool loadMore = false}) async {
    try {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection('foods')
          .where('type', isEqualTo: _type)
          .orderBy('searchName')
          .startAt([_searchText.toLowerCase()])
          .endAt(['${_searchText.toLowerCase()}\uf8ff'])
          .limit(pageSize);

      if (lastDoc != null && loadMore) {
        query = query.startAfterDocument(lastDoc!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        lastDoc = snapshot.docs.last;
      }

      setState(() {
        foods.addAll(snapshot.docs.map(Food.fromFirestore).toList());
      });
    } catch (e) {
      print(e);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Uusi ateria listalta'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsetsGeometry.all(20),
        child: Column(
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Ateria'),
                  selected: _type == 'Ateria',
                  onSelected: (value) {
                    setState(() {
                      _type = 'Ateria';
                      loadFoodsFresh();
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('Välipala'),
                  selected: _type == 'Välipala',
                  onSelected: (value) {
                    setState(() {
                      _type = 'Välipala';
                      loadFoodsFresh();
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('Herkku'),
                  selected: _type == 'Herkku',
                  onSelected: (value) {
                    setState(() {
                      _type = 'Herkku';
                      loadFoodsFresh();
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('Lisuke'),
                  selected: _type == 'Lisuke',
                  onSelected: (value) {
                    setState(() {
                      _type = 'Lisuke';
                      loadFoodsFresh();
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('Juoma'),
                  selected: _type == 'Juoma',
                  onSelected: (value) {
                    setState(() {
                      _type = 'Juoma';
                      loadFoodsFresh();
                    });
                  },
                ),
              ],
            ),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Hae...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                  loadFoodsFresh();
                });
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: foods.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(foods[index].name.toString()),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddMealFromMenuPage(food: foods[index]),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
