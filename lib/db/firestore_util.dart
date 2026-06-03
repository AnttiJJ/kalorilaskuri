import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUtil {
  static final db = FirebaseFirestore.instance;

  Future<String> read() async {
    final food = await db
        .collection('foods')
        .where('name', isEqualTo: 'kanapasta')
        .limit(1)
        .get();

    final doc = food.docs[0].data();
    return doc['calors'];
  }
}
