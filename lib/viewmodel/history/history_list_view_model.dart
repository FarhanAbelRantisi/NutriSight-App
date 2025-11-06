import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../data/history_repository.dart';

class HistoryListViewModel extends ChangeNotifier {
  final HistoryRepository _repository;
  final String userId;

  HistoryListViewModel({
    required this.userId,
    HistoryRepository? repository,
  }) : _repository = repository ?? HistoryRepository();

  Stream<QuerySnapshot<Map<String, dynamic>>> get historyStream =>
      _repository.watchHistory(userId);
}
