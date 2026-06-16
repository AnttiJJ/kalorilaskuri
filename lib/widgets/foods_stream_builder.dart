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
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Food>>(
      stream: FirebaseFirestore.instance
          .collection('foods')
          .where('type', isEqualTo: widget.type)
          .snapshots()
          .map((snapshot) => snapshot.docs.map(Food.fromFirestore).toList()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final foods = snapshot.data!;

        return ListView.builder(
          itemCount: foods.length,
          itemBuilder: (context, index) {
            final food = foods[index];

            return FoodCard(food: food);
          },
        );
      },
    );
  }
}
