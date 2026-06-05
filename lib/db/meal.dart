class Meal {
  final int? id;
  final String name;
  final int calories;
  final String type;
  final int? weight;
  final String? size;
  final int? amount;
  final String createdAt;

  Meal({
    this.id,
    required this.name,
    required this.calories,
    required this.type,
    this.weight,
    this.size,
    this.amount,
    required this.createdAt,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'type': type,
      'weight': weight,
      'size': size,
      'amount': amount,
      'created_at': createdAt,
    };
  }
}
