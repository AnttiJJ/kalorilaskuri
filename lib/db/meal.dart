class Meal {
  final int? id;
  final String name;
  final int calories;
  final String createdAt;

  Meal({
    this.id,
    required this.name,
    required this.calories,
    required this.createdAt,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'created_at': createdAt,
    };
  }

  @override
  String toString() {
    return 'Meal(id: $id, name: $name, calories: $calories, created_at: $createdAt)';
  }
}
