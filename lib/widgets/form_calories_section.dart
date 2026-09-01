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
              InkWell(
                onTap: () {
                  onChanged('Paino');
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Paino', style: TextStyle(fontSize: 18)),
                    Switch(
                      value: mealSizeType == 'Paino',
                      padding: EdgeInsets.all(10),
                      onChanged: (value) {
                        onChanged('Paino');
                      },
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Spacer(),
                  Expanded(
                    child: TextFormField(
                      controller: weightController,
                      maxLength: 4,
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
                  Spacer(),
                ],
              ),
              Center(
                child: Text(
                  '${food.caloriesPer100g!.toString()} kcal/100g',
                  style: mealSizeType != 'Paino'
                      ? TextStyle(color: Colors.grey)
                      : null,
                ),
              ),
            ],
          ),
        SizedBox(height: 30),
        if (food.caloriesPerPiece != null)
          Column(
            children: [
              InkWell(
                onTap: () {
                  onChanged('Määrä');
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Määrä', style: TextStyle(fontSize: 18)),
                    Switch(
                      value: mealSizeType == 'Määrä',
                      padding: EdgeInsets.all(10),
                      onChanged: (value) {
                        onChanged('Määrä');
                      },
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(child: SizedBox()),
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: mealSizeType == 'Määrä'
                              ? () {
                                  final amount =
                                      int.tryParse(amountController.text) ?? 0;

                                  if (amount > 0) {
                                    amountController.text = (amount - 1)
                                        .toString();
                                  }
                                }
                              : null,
                          icon: const Icon(Icons.remove),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: amountController,
                            maxLength: 3,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
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

                        IconButton(
                          onPressed: mealSizeType == 'Määrä'
                              ? () {
                                  final amount =
                                      int.tryParse(amountController.text) ?? 0;

                                  amountController.text = (amount + 1)
                                      .toString();
                                }
                              : null,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: SizedBox()),
                ],
              ),
              Center(
                child: Text(
                  '${food.caloriesPerPiece!.toString()} kcal/kpl',
                  style: mealSizeType != 'Määrä'
                      ? TextStyle(color: Colors.grey)
                      : null,
                ),
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
                    label: Icon(Icons.circle, size: 16),
                  ),
                  ButtonSegment(
                    value: 'Normaali',
                    enabled: food.caloriesPerSize!['Normaali'] != null,
                    label: Icon(Icons.circle, size: 22),
                  ),
                  ButtonSegment(
                    value: 'Iso',
                    enabled: food.caloriesPerSize!['Iso'] != null,
                    label: Icon(Icons.circle, size: 28),
                  ),
                ],
                selected: {mealSizeType},
                onSelectionChanged: (selection) {
                  onChanged(selection.first);
                },
              ),
              Text(
                mealSizeType != 'Määrä' && mealSizeType != 'Paino'
                    ? '${food.caloriesPerSize![mealSizeType].toString()} kcal'
                    : '',
              ),
            ],
          ),
        SizedBox(height: 20),
      ],
    );
  }
}
