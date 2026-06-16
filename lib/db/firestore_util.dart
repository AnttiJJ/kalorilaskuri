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

  Future<bool> isNameAvailable(String name) async {
    try {
      final doc = await db.collection('foods').doc(name).get();
      if (doc.exists) {
        return false;
      }
      return true;
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
      if (await isNameAvailable(food.name)) {
        await _doAddFood(food);
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> read() async {
    final food = await db
        .collection('foods')
        .where('name', isEqualTo: 'kanapasta')
        .limit(1)
        .get();

    final doc = food.docs[0].data();
    return doc['calors'];
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getFoods(String type) async {
    try {
      final foods = await db
          .collection('foods')
          .where('type', isEqualTo: type)
          .get();

      return foods;
    } catch (e) {
      rethrow;
    }
  }
}
