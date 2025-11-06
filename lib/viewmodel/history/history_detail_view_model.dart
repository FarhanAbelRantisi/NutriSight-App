import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../data/history_repository.dart';

class HistoryDetailViewModel extends ChangeNotifier {
  final HistoryRepository _repository;
  final String userId;
  final String docId;
  final Map<String, dynamic> rawData;

  bool isDeleting = false;

  HistoryDetailViewModel({
    required this.userId,
    required this.docId,
    required this.rawData,
    HistoryRepository? repository,
  }) : _repository = repository ?? HistoryRepository();

  String get categoryName =>
      (rawData['categoryName'] ?? 'Tidak diketahui').toString();

  String get grade => (rawData['grade'] ?? 'N/A').toString();

  String? get imageLocalPath {
    final path = (rawData['imageLocalPath'] ?? '').toString();
    if (path.isEmpty) return null;
    return path;
  }

  bool get imageExists =>
      imageLocalPath != null && File(imageLocalPath!).existsSync();

  Map<String, dynamic> get scanResult {
    final sr = rawData['scanResult'];
    if (sr is Map<String, dynamic>) return sr;
    return {};
  }

  Map<String, dynamic> get nerResults {
    final possibleKeys = [
      'debug_ner_results',
      'extracted_fields',
      'ner',
      'parsed_fields',
      'fields',
    ];
    for (final k in possibleKeys) {
      final val = scanResult[k];
      if (val is Map<String, dynamic> && val.isNotEmpty) {
        return val;
      }
    }
    return <String, dynamic>{};
  }

  String formatNerKey(String key) {
    if (key.isEmpty) return "N/A";
    return key
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .map((w) =>
            w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  Future<void> deleteHistory() async {
    if (isDeleting) return;
    isDeleting = true;
    notifyListeners();

    try {
      await _repository.deleteHistory(userId: userId, docId: docId);
    } finally {
      isDeleting = false;
      notifyListeners();
    }
  }
}
