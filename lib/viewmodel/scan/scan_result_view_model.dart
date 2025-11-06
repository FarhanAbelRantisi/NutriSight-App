import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ScanResultViewModel extends ChangeNotifier {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  final String imagePath;
  final String categoryName;
  final Map<String, dynamic> scanResult;

  bool isSaving = false;
  bool isSaved = false;

  ScanResultViewModel({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    required this.imagePath,
    required this.categoryName,
    required this.scanResult,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  String get grade {
    final candidates = [
      scanResult['grade'],
      scanResult['predicted_grade'],
      scanResult['nutri_grade'],
      scanResult['result'] is Map ? (scanResult['result'] as Map)['grade'] : null,
    ];

    for (var c in candidates) {
      if (c == null) continue;
      final s = c.toString().trim();
      if (s.isNotEmpty && s.toUpperCase() != 'N/A') {
        return s.toUpperCase();
      }
    }
    return 'N/A';
  }

  Map<String, dynamic> get nerResults {
    final possibleKeys = [
      'debug_ner_results',
      'extracted_fields',
      'ner',
      'parsed_fields',
      'fields',
    ];

    for (final key in possibleKeys) {
      final val = scanResult[key];
      if (val is Map<String, dynamic> && val.isNotEmpty) {
        return val;
      }
    }

    final val = scanResult['debug_ner_results'];
    if (val is List && val.isNotEmpty) {
      final Map<String, dynamic> converted = {};
      for (final item in val) {
        if (item is Map && item['key'] != null) {
          converted[item['key'].toString()] = item['value'] ?? '';
        }
      }
      if (converted.isNotEmpty) return converted;
    }

    return {};
  }

  String formatNerKey(String key) {
    if (key.isEmpty) return "N/A";
    return key
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  Future<void> toggleBookmark() async {
    if (isSaving) return;

    isSaving = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception("Kamu belum login.");
      }

      final collection = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('history');

      final existing = await collection
          .where('categoryName', isEqualTo: categoryName)
          .where('grade', isEqualTo: grade)
          .where('imageLocalPath', isEqualTo: imagePath)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        await collection.doc(existing.docs.first.id).delete();
        isSaved = false;
      } else {
        await collection.add({
          'categoryName': categoryName,
          'grade': grade,
          'scanResult': scanResult,
          'imageLocalPath': imagePath,
          'createdAt': FieldValue.serverTimestamp(),
        });
        isSaved = true;
      }
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
