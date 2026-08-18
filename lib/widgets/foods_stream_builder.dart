import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kalorilaskuri/db/food.dart';
import 'package:kalorilaskuri/widgets/food_card.dart';

class FoodsStreamBuilder extends StatefulWidget {
  final String type;

  const FoodsStreamBuilder({super.key, required this.type});

  @override
  State<FoodsStreamBuilder> createState() => _FoodsStreamBuilderState();
}

class _FoodsStreamBuilderState extends State<FoodsStreamBuilder> {
  final int pageSize = 5;

  String _searchText = '';
  DocumentSnapshot<Map<String, dynamic>>? lastDoc;
  List<Food> foods = [];
  bool hasMoreFoods = false;

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
          .where('type', isEqualTo: widget.type)
          .orderBy('searchName')
          .startAt([_searchText.toLowerCase()])
          .endAt(['${_searchText.toLowerCase()}\uf8ff'])
          .limit(pageSize + 1);

      if (lastDoc != null && loadMore) {
        query = query.startAfterDocument(lastDoc!);
      }

      final snapshot = await query.get();

      final hasMore = snapshot.docs.length > pageSize;
      final docs = hasMore ? snapshot.docs.sublist(0, pageSize) : snapshot.docs;

      if (snapshot.docs.isNotEmpty) {
        lastDoc = docs.last;
      }

      setState(() {
        foods.addAll(docs.map(Food.fromFirestore).toList());
        hasMoreFoods = hasMore;
      });

      return;
    } catch (e) {
      print(e);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
          child: Container(
            margin: const EdgeInsets.only(bottom: 20.0),
            child: ListView.builder(
              itemCount: hasMoreFoods ? foods.length + 1 : foods.length,
              itemBuilder: (context, index) {
                if (index == foods.length && hasMoreFoods) {
                  return FilledButton(
                    onPressed: () => loadFoods(loadMore: true),
                    child: Text('Lisää'),
                  );
                }
                final food = foods[index];

                return FoodCard(
                  food: food,
                  onChanged: () {
                    setState(() {
                      loadFoodsFresh();
                    });
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
