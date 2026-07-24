import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kalorilaskuri/db/food.dart';
import 'package:kalorilaskuri/db/meal.dart';
import 'package:kalorilaskuri/widgets/form_calories_section.dart';

class AddExtraDialog extends StatefulWidget {
  final String type;

  const AddExtraDialog({super.key, required this.type});

  @override
  State<AddExtraDialog> createState() => _AddExtraDialogState();
}

class _AddExtraDialogState extends State<AddExtraDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _weightController = TextEditingController();

  String _searchText = '';
  Food? _selectedFood;
  String? _mealSizeType;

  @override
  void dispose() {
    _amountController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void saveExtra() {
    final name = _selectedFood!.name;
    final type = _selectedFood!.type;

    DateTime date = DateTime.now();
    int calories = 0;
    int? weight;
    int? amount;
    String? size;

    switch (_mealSizeType) {
      case 'Paino':
        weight = int.parse(_weightController.text);
        calories = weight * _selectedFood!.caloriesPer100g! ~/ 100;
        break;
      case 'Määrä':
        amount = int.parse(_amountController.text);
        calories = amount * _selectedFood!.caloriesPerPiece!;
        break;
      case 'Pieni':
        size = 'Pieni';
        calories = _selectedFood!.caloriesPerSize!['Pieni']!;
        break;
      case 'Normaali':
        size = 'Normaali';
        calories = _selectedFood!.caloriesPerSize!['Normaali']!;
        break;
      case 'Iso':
        size = 'Iso';
        calories = _selectedFood!.caloriesPerSize!['Iso']!;
        break;
      default:
    }

    final Meal meal = Meal(
      name: name,
      calories: calories,
      type: type,
      weight: weight,
      size: size,
      amount: amount,
      createdAt: date.toIso8601String(),
      fromMenu: 1,
    );

    if (!mounted) return;

    Navigator.pop(context, meal);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _selectedFood == null ? 'Valitse ${widget.type}' : _selectedFood!.name,
        textAlign: TextAlign.center,
      ),
      content: _selectedFood == null
          ? SizedBox(
              height: 400,
              width: 400,
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Hae...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('foods')
                          .where('type', isEqualTo: widget.type)
                          .orderBy('searchName')
                          .startAt([_searchText.toLowerCase()])
                          .endAt(['${_searchText.toLowerCase()}\uf8ff'])
                          .limit(10)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final foods = snapshot.data!.docs
                            .map((doc) => Food.fromFirestore(doc))
                            .toList();

                        if (foods.isEmpty) {
                          return const Center(child: Text('No foods found'));
                        }

                        return ListView.builder(
                          itemCount: foods.length,
                          itemBuilder: (context, index) {
                            final food = foods[index];

                            return ListTile(
                              title: Text(food.name),
                              onTap: () {
                                setState(() {
                                  _selectedFood = food;
                                });
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          : SizedBox(
              height: 400,
              width: 400,
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        FormCaloriesSection(
                          food: _selectedFood!,
                          mealSizeType: _mealSizeType,
                          weightController: _weightController,
                          amountController: _amountController,
                          onChanged: (value) {
                            setState(() {
                              _mealSizeType = value;
                            });
                          },
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              saveExtra();
                            }
                          },
                          child: const Text('Tallenna'),
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
