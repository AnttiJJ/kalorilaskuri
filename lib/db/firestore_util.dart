import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kalorilaskuri/utils/extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirestoreUtil {
  static final db = FirebaseFirestore.instance;

  Future<void> addCalories(int calories, String type, DateTime datetime) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = prefs.getString('user');
      final date = Timestamp.fromDate(datetime);
      String id = await createId(datetime);

      final doc = await db.collection('calories').doc(id).get();

      if (doc.exists) {
        updateCalories(doc, calories, type);
      } else {
        final newDoc = <String, dynamic>{
          'user': user,
          'date': date,
          type: calories,
        };
        await db.collection('calories').doc(id).set(newDoc);
      }
    } catch (e) {
      print(e);
      return;
    }
  }

  Future<void> updateCalories(
    DocumentSnapshot<Map<String, dynamic>> doc,
    int calories,
    String type,
  ) async {
    final int newCalories = calculateNewCalories(doc, calories, type);

    await db.collection('calories').doc(doc.id).update({type: newCalories});
  }

  Future<void> removeCalories(
    int calories,
    String type,
    DateTime datetime,
  ) async {
    try {
      final id = await createId(datetime);
      final doc = await db.collection('calories').doc(id).get();

      await updateCalories(doc, -calories, type);
    } catch (e) {
      print(e);
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

  Future<String> createId(DateTime datetime) async {
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString('user');
    return '${user}_${datetime.formatDate}';
  }

  int calculateNewCalories(
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
}
