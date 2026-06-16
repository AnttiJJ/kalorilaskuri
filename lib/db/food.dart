import 'package:cloud_firestore/cloud_firestore.dart';

class Food {
  final String name;
  final String type;
  final int? caloriesPer100g;
  final int? caloriesPerPiece;
  final Map<String, int?>? caloriesPerSize;

  Food({
    required this.name,
    required this.type,
    required this.caloriesPer100g,
    required this.caloriesPerPiece,
    required this.caloriesPerSize,
  });

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'type': type,
      'caloriesPer100g': caloriesPer100g,
      'caloriesPerPiece': caloriesPerPiece,
      'caloriesPerSize': caloriesPerSize,
    };
  }

  factory Food.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final sizeCaldata = data['caloriesPerSize'] as Map<String, dynamic>?;

    return Food(
      name: doc.id,
      type: data['type'] as String,
      caloriesPer100g: data['caloriesPer100g'] as int?,
      caloriesPerPiece: data['caloriesPerPiece'] as int?,
      caloriesPerSize: sizeCaldata?.map(
        (key, value) => MapEntry(key, value as int?),
      ),
    );
  }
}
