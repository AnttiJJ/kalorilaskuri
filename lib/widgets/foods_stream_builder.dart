import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('foods')
          .where('type', isEqualTo: widget.type)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final foods = snapshot.data!.docs;

        return ListView.builder(
          itemCount: foods.length,
          itemBuilder: (context, index) {
            final food = foods[index].data();

            return FoodCard(food: food);
          },
        );
      },
    );
  }
}
