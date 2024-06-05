import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchData() async {
    var result = await _db.collection('your_collection').get();
    return result.docs.map((doc) => doc.data()).toList();
  }

  Future<void> addData(Map<String, dynamic> data) async {
    await _db.collection('your_collection').add(data);
  }

  Future<void> updateData(String id, Map<String, dynamic> data) async {
    await _db.collection('your_collection').doc(id).update(data);
  }

  Future<void> deleteData(String id) async {
    await _db.collection('your_collection').doc(id).delete();
  }
}
