import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryRepository {
  final FirebaseFirestore _firestore;

  HistoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> watchHistory(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('history')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> deleteHistory({
    required String userId,
    required String docId,
  }) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('history')
        .doc(docId)
        .delete();
  }
}
