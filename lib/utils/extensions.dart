import 'package:flutter/material.dart';
import 'package:kalorilaskuri/db/food.dart';
import 'package:kalorilaskuri/db/meal.dart';

extension DateFormatting on DateTime {
  String get formatDate =>
      '${day.toString().padLeft(2, '0')}.'
      '${month.toString().padLeft(2, '0')}.'
      '$year';
}

extension FoodFormExtension on Food {
  int calculateCalories(
    String sizeType,
    TextEditingController amountController,
    TextEditingController weightController,
  ) {
    int calories = 0;
    int? weight;
    int? amount;

    switch (sizeType) {
      case 'Paino':
        if (weightController.text != '') {
          weight = int.parse(weightController.text);
          calories = weight * caloriesPer100g! ~/ 100;
        }
        break;
      case 'Määrä':
        if (amountController.text != '') {
          amount = int.parse(amountController.text);
          calories = amount * caloriesPerPiece!;
        }
        break;
      case 'Pieni':
        calories = caloriesPerSize!['Pieni']!;
        break;
      case 'Normaali':
        calories = caloriesPerSize!['Normaali']!;
        break;
      case 'Iso':
        calories = caloriesPerSize!['Iso']!;
        break;
      default:
    }

    return calories;
  }

  String get primarySizeType {
    if (caloriesPerSize != null) {
      return caloriesPerSize!.entries
          .where((entry) => entry.value != null)
          .last
          .key;
    } else if (caloriesPerPiece != null) {
      return 'Määrä';
    }

    return 'Paino';
  }
}

extension MealSizeExtension on String {
  // Return pieni, normaali tai iso if selected, otherwise null
  String? get getMealSize {
    if (this != 'Paino' && this != 'Määrä') {
      return this;
    }
    return null;
  }

  int? getPossibleWeight(TextEditingController weightController) {
    return this == 'Paino' ? int.parse(weightController.text) : null;
  }

  int? getPossibleAmount(TextEditingController amountController) {
    return this == 'Määrä' ? int.parse(amountController.text) : null;
  }
}

extension MealListExtension on List<Meal> {
  int get totalCalories {
    return fold<int>(0, (sum, meal) => sum + (meal.calories));
  }
}
