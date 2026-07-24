import 'package:kalorilaskuri/db/firestore_util.dart';
import 'package:kalorilaskuri/db/meal.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqfliteUtil {
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;

    _db = await openDatabase(
      join(await getDatabasesPath(), 'kalorilaskuri_database.db'),
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE meals(id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'parent_meal_id INTEGER, '
          'name TEXT NOT NULL, '
          'calories INTEGER NOT NULL, '
          'type TEXT NOT NULL, '
          'weight INTEGER, '
          'size TEXT, '
          'amount INTEGER, '
          'created_at TEXT NOT NULL, '
          'from_menu INTEGER NOT NULL, '
          'FOREIGN KEY (parent_meal_id) REFERENCES meals(id))',
        );
      },
      version: 1,
    );

    return _db!;
  }

  Future<int> insertMeal(Meal meal) async {
    final db = await database;

    return await db.insert(
      'meals',
      meal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateMeal(Meal meal) async {
    final db = await database;

    await db.update(
      'meals',
      meal.toMap(),
      where: 'id = ?',
      whereArgs: [meal.id],
    );
  }

  Future<List<Meal>> getMeals(DateTime datetime) async {
    final db = await database;
    final start = DateTime(datetime.year, datetime.month, datetime.day);
    final end = start.add(const Duration(days: 1));

    final List<Map<String, Object?>> mealMaps = await db.query(
      'meals',
      where: 'created_at >= ? AND created_at < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
    );

    return [
      for (final {
            'id': id as int,
            'parent_meal_id': parentMealId as int?,
            'name': name as String,
            'calories': calories as int,
            'type': type as String,
            'weight': weight as int?,
            'size': size as String?,
            'amount': amount as int?,
            'created_at': createdAt as String,
            'from_menu': fromMenu as int,
          }
          in mealMaps)
        Meal(
          id: id,
          parentMealId: parentMealId,
          name: name,
          calories: calories,
          type: type,
          weight: weight,
          size: size,
          amount: amount,
          createdAt: createdAt,
          fromMenu: fromMenu,
        ),
    ];
  }

  Future<void> deleteMeal(
    int id,
    int calories,
    String type,
    DateTime datetime,
  ) async {
    try {
      final db = await database;
      final FirestoreUtil firestoreUtil = FirestoreUtil();

      await firestoreUtil.updateCalories(-calories, type, datetime);

      await db.delete('meals', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      rethrow;
    }
  }
}
