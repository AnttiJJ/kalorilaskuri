import 'package:flutter/material.dart';

class Meal {
  final int? id;
  final String name;
  final int calories;
  final String type;
  final int? weight;
  final String? size;
  final int? amount;
  final String createdAt;
  final int fromMenu;

  Meal({
    this.id,
    required this.name,
    required this.calories,
    required this.type,
    this.weight,
    this.size,
    this.amount,
    required this.createdAt,
    required this.fromMenu,
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
      'from_menu': fromMenu,
    };
  }

  Icon get icon {
    switch (type) {
      case 'Välipala':
        return Icon(Icons.apple, color: Colors.orange[300]);
      case 'Herkku':
        return Icon(Icons.cake, color: Colors.red[300]);
      case 'Lisuke':
        return Icon(Icons.breakfast_dining, color: Colors.blue[300]);
      case 'Juoma':
        return Icon(Icons.coffee, color: Colors.brown[300]);
      default:
        return Icon(Icons.restaurant_menu, color: Colors.green[300]);
    }
  }

  String get mealSize {
    if (size != null) {
      return 'Koko: $size';
    } else if (amount != null) {
      return 'Määrä: $amount kpl';
    } else {
      return 'Paino: $weight g';
    }
  }
}
