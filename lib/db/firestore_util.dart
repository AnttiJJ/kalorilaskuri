import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kalorilaskuri/db/food.dart';
import 'package:kalorilaskuri/utils/extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirestoreUtil {
  static final db = FirebaseFirestore.instance;

  // ******************************
  // ********** CALORIES **********
  // ******************************

  Future<void> addCalories(int calories, String type, DateTime datetime) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = prefs.getString('user');
      final date = Timestamp.fromDate(datetime);
      String id = await createId(datetime);

      final doc = await db.collection('calories').doc(id).get();

      if (doc.exists) {
        _doUpdateCalories(doc, calories, type);
      } else {
        final newDoc = <String, dynamic>{
          'user': user,
          'date': date,
          type: calories,
        };
        await db.collection('calories').doc(id).set(newDoc);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _doUpdateCalories(
    DocumentSnapshot<Map<String, dynamic>> doc,
    int calories,
    String type,
  ) async {
    try {
      final int newCalories = _calculateNewCalories(doc, calories, type);

      await db.collection('calories').doc(doc.id).update({type: newCalories});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCalories(
    int calories,
    String type,
    DateTime datetime,
  ) async {
    try {
      final id = await createId(datetime);
      final doc = await db.collection('calories').doc(id).get();

      await _doUpdateCalories(doc, calories, type);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> createId(DateTime datetime) async {
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString('user');
    return '${user}_${datetime.formatDate}';
  }

  int _calculateNewCalories(
    DocumentSnapshot<Map<String, dynamic>> doc,
    int calories,
    String type,
  ) {
    final data = doc.data();
    final oldCalories = data?[type];
    final int newCalories = oldCalories != null
        ? oldCalories + calories
        : calories;

    return newCalories;
  }

  // ***************************
  // ********** FOODS **********
  // ***************************

  Future<Food> getFood(String name) async {
    try {
      final doc = await db.collection('foods').doc(name).get();
      if (!doc.exists) {
        throw Exception('Food not found');
      }

      final food = Food.fromFirestore(doc);
      return food;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> foodExists(String name) async {
    try {
      final doc = await db.collection('foods').doc(name).get();
      if (doc.exists) {
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _doAddFood(Food food) async {
    try {
      await db.collection('foods').doc(food.name).set(food.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> addFood(Food food) async {
    try {
      if (await foodExists(food.name)) {
        return false;
      } else {
        await _doAddFood(food);
        return true;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateFood(Food food) async {
    try {
      if (await foodExists(food.name)) {
        await db.collection('foods').doc(food.name).update({
          'type': food.type,
          'caloriesPer100g': food.caloriesPer100g,
          'caloriesPerPiece': food.caloriesPerPiece,
          'caloriesPerSize': food.caloriesPerSize,
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteFood(String name) async {
    try {
      await db.collection('foods').doc(name).delete();
    } catch (e) {
      rethrow;
    }
  }
}
