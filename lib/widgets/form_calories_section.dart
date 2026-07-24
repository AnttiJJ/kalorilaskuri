import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kalorilaskuri/db/food.dart';

class FormCaloriesSection extends StatelessWidget {
  final Food food;
  final String? mealSizeType;
  final TextEditingController weightController;
  final TextEditingController amountController;
  final ValueChanged<String?> onChanged;

  const FormCaloriesSection({
    super.key,
    required this.food,
    required this.mealSizeType,
    required this.weightController,
    required this.amountController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (food.caloriesPer100g != null)
          Column(
            children: [
              Center(
                child: Text(
                  '${food.caloriesPer100g!.toString()} kcal/100g',
                  style: mealSizeType != 'Paino'
                      ? TextStyle(color: Colors.grey)
                      : null,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: SwitchListTile(
                      title: const Text('Paino'),
                      value: mealSizeType == 'Paino',
                      onChanged: (value) {
                        onChanged('Paino');
                      },
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: weightController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      enabled: mealSizeType == 'Paino',
                      decoration: const InputDecoration(labelText: 'g'),
                      validator: (value) {
                        if (mealSizeType != 'Paino') {
                          return null;
                        }

                        if (value == null || value.isEmpty) {
                          return 'Anna paino';
                        }

                        final number = int.tryParse(value);

                        if (number == null || number <= 0) {
                          return 'Anna paino positiivisena lukuna';
                        }

                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        if (food.caloriesPerPiece != null)
          Column(
            children: [
              Center(
                child: Text(
                  '${food.caloriesPerPiece!.toString()} kcal/kpl',
                  style: mealSizeType != 'Määrä'
                      ? TextStyle(color: Colors.grey)
                      : null,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: SwitchListTile(
                      title: const Text('Määrä'),
                      value: mealSizeType == 'Määrä',
                      onChanged: (value) {
                        onChanged('Määrä');
                      },
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      enabled: mealSizeType == 'Määrä',
                      decoration: const InputDecoration(labelText: 'kpl'),
                      validator: (value) {
                        if (mealSizeType != 'Määrä') {
                          return null;
                        }

                        if (value == null || value.isEmpty) {
                          return 'Anna määrä';
                        }

                        final number = int.tryParse(value);

                        if (number == null || number <= 0) {
                          return 'Anna määrä positiivisena lukuna';
                        }

                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        SizedBox(height: 30),
        if (food.caloriesPerSize != null)
          Column(
            children: [
              Text('Annokset', style: TextStyle(fontSize: 20)),
              SizedBox(height: 20),
              SegmentedButton(
                segments: [
                  ButtonSegment(
                    value: 'Pieni',
                    enabled: food.caloriesPerSize!['Pieni'] != null,
                    label: const Text('Pieni'),
                  ),
                  ButtonSegment(
                    value: 'Normaali',
                    enabled: food.caloriesPerSize!['Normaali'] != null,
                    label: const Text('Normaali'),
                  ),
                  ButtonSegment(
                    value: 'Iso',
                    enabled: food.caloriesPerSize!['Iso'] != null,
                    label: const Text('Iso'),
                  ),
                ],
                selected: {mealSizeType},
                onSelectionChanged: (selection) {
                  onChanged(selection.first);
                },
              ),
            ],
          ),
      ],
    );
  }
}
