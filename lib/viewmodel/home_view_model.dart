import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../data/product_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final ProductRepository _repository;

  HomeViewModel(this._repository);

  bool isLoading = true;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> allProducts = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> filteredProducts = [];

  List<String> allCategories = ['All'];
  String selectedGrade = 'All';
  String selectedCategory = 'All';
  String searchQuery = '';

  Future<void> init() async {
    try {
      isLoading = true;
      notifyListeners();

      final docs = await _repository.fetchProducts();

      final Set<String> categories = {'All'};
      for (var doc in docs) {
        final data = doc.data();
        final categoryName = (data['categoryName'] ?? '').toString();
        if (categoryName.isNotEmpty) {
          categories.add(categoryName);
        }
      }

      allProducts = docs;
      allCategories = categories.toList()..sort();

      _applyFiltersInternal();
    } catch (e) {
      debugPrint("🔥 error fetch: $e");
      isLoading = false;
      notifyListeners();
    }
  }

  void updateSearch(String query) {
    searchQuery = query.toLowerCase();
    _applyFiltersInternal();
  }

  void setSelectedGrade(String grade) {
    selectedGrade = grade;
    _applyFiltersInternal();
  }

  void setSelectedCategory(String category) {
    selectedCategory = category;
    _applyFiltersInternal();
  }

  void _applyFiltersInternal() {
    List<QueryDocumentSnapshot<Map<String, dynamic>>> result =
        List.from(allProducts);

    if (selectedGrade != 'All') {
      result = result.where((doc) {
        final grade = (doc.data()['grade'] ?? '').toString();
        return grade == selectedGrade;
      }).toList();
    }

    if (selectedCategory != 'All') {
      result = result.where((doc) {
        final cat = (doc.data()['categoryName'] ?? '').toString();
        return cat == selectedCategory;
      }).toList();
    }

    if (searchQuery.isNotEmpty) {
      result = result.where((doc) {
        final data = doc.data();
        final nameLower =
            (data['productName_lowercase'] ?? '').toString().toLowerCase();
        final barcodeLower =
            (data['barcode'] ?? '').toString().toLowerCase();

        return nameLower.contains(searchQuery) ||
            barcodeLower.contains(searchQuery);
      }).toList();
    }

    filteredProducts = result;
    isLoading = false;
    notifyListeners();
  }
}
