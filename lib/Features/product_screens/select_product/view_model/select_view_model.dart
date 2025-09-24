import 'package:flutter/material.dart';

import '../../../../Service/firebase_service.dart';
import '../../product/model/product_model.dart';

class SelectProductViewModel extends ChangeNotifier {
  List<ProductTypeModel> _productTypes = [];
  List<ProductTypeModel> _filteredProductTypes = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  List<ProductTypeModel> get productTypes => _filteredProductTypes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProductTypes() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _productTypes = await FirebaseService.getProductTypes();
      _filteredProductTypes = _productTypes;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchProductTypes(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredProductTypes = _productTypes;
    } else {
      _filteredProductTypes = _productTypes
          .where((product) => product.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}