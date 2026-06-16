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
}
