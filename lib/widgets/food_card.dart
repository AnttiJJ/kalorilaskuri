import 'package:flutter/material.dart';

class FoodCard extends StatefulWidget {
  final Map<String, dynamic> food;

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
    weightCal = widget.food['caloriesPer100g'];
    pieceCal = widget.food['caloriesPerPiece'];
    sizeCal = widget.food['caloriesPerSize'];
    super.initState();
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
              title: Text(widget.food['name']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.mode, color: Colors.blue),
                  ),
                  IconButton(
                    onPressed: () {},
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
