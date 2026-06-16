import 'package:flutter/material.dart';
import 'package:kalorilaskuri/db/firestore_util.dart';
import 'package:kalorilaskuri/db/food.dart';
import 'package:kalorilaskuri/pages/update_food_page.dart';

class FoodCard extends StatefulWidget {
  final Food food;

  const FoodCard({super.key, required this.food});

  @override
  State<FoodCard> createState() => _FoodCardState();
}

class _FoodCardState extends State<FoodCard> {
  bool expanded = false;
  int? weightCal;
  int? pieceCal;
  Map<String, dynamic>? sizeCal;

  @override
  void initState() {
    weightCal = widget.food.caloriesPer100g;
    pieceCal = widget.food.caloriesPerPiece;
    sizeCal = widget.food.caloriesPerSize;
    super.initState();
  }

  Future<void> deleteFood(String name) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Poista ruoka'),
          content: Text('Haluatko varmasti poistaa $name ruoan'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Peruuta'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Poista'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        final FirestoreUtil firestoreUtil = FirestoreUtil();
        firestoreUtil.deleteFood(name);
      } catch (e) {
        print(e);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          setState(() {
            expanded = !expanded;
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(widget.food.name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UpdateFoodPage(food: widget.food),
                        ),
                      );
                      //setState(() {});
                    },
                    icon: Icon(Icons.mode, color: Colors.blue),
                  ),
                  IconButton(
                    onPressed: () => deleteFood(widget.food.name),
                    icon: Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            ),
            if (expanded)
              Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kalorit:', style: TextStyle(fontSize: 16)),
                    if (weightCal != null) Text('100g = $weightCal kcal'),
                    if (pieceCal != null) Text('Kpl = $pieceCal kcal'),
                    if (sizeCal != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          Text('Annoskoko:'),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (sizeCal!['Pieni'] != null)
                                Text('Pieni: ${sizeCal!['Pieni']} kcal'),
                              if (sizeCal!['Normaali'] != null)
                                Text('Normaali: ${sizeCal!['Normaali']} kcal'),
                              if (sizeCal!['Iso'] != null)
                                Text('Iso: ${sizeCal!['Iso']} kcal'),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
