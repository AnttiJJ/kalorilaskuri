import 'package:kalorilaskuri/db/meal.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqfliteUtil {
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;

    _db = await openDatabase(
      join(await getDatabasesPath(), 'kalorilaskuri_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE meals(id INTEGER PRIMARY KEY, name TEXT NOT NULL, calories INTEGER NOT NULL, type TEXT NOT NULL, weight INTEGER, size TEXT, amount INTEGER, created_at TEXT NOT NULL)',
        );
      },
      version: 1,
    );

    return _db!;
  }

  Future<void> insertMeal(Meal meal) async {
    final db = await database;

    await db.insert(
      'meals',
      meal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Meal>> getMeals() async {
    final db = await database;

    final List<Map<String, Object?>> mealMaps = await db.query('meals');

    return [
      for (final {
            'id': id as int,
            'name': name as String,
            'calories': calories as int,
            'type': type as String,
            'weight': weight as int?,
            'size': size as String?,
            'amount': amount as int?,
            'created_at': createdAt as String,
          }
          in mealMaps)
        Meal(
          id: id,
          name: name,
          calories: calories,
          type: type,
          weight: weight,
          size: size,
          amount: amount,
          createdAt: createdAt,
        ),
    ];
  }

  Future<void> deleteMeal(int id) async {
    final db = await database;

    await db.delete('meals', where: 'id = ?', whereArgs: [id]);
  }
}
