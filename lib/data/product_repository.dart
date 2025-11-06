import 'package:cloud_firestore/cloud_firestore.dart';

class ProductRepository {
  final FirebaseFirestore firestore;

  ProductRepository(this.firestore);

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchProducts() async {
    final snap = await firestore
        .collection('products')
        .orderBy('productName_lowercase')
        .limit(60)
        .get();

    return snap.docs;
  }
}
