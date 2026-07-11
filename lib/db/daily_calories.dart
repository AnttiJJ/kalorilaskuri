import 'package:cloud_firestore/cloud_firestore.dart';

class DailyCalories {
  final int meals;
  final int snacks;
  final int sweets;
  final int drinks;
  final int extras;
  final int used;

  DailyCalories({
    required this.meals,
    required this.snacks,
    required this.sweets,
    required this.drinks,
    required this.extras,
    required this.used,
  });

  factory DailyCalories.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return DailyCalories(
      meals: data['Ateria'] ?? 0,
      snacks: data['Välipala'] ?? 0,
      sweets: data['Herkku'] ?? 0,
      drinks: data['Juoma'] ?? 0,
      extras: data['Lisuke'] ?? 0,
      used: data['Kulutettu'] ?? 0,
    );
  }

  int consumed() {
    return meals + snacks + sweets + drinks + extras;
  }

  int difference() {
    return consumed() - used;
  }
}
