import 'package:flutter/material.dart';
import '../../../../Service/firebase_service.dart';

class SelectBrandViewModel extends ChangeNotifier {
  List<String> _brands = [];
  List<String> _filteredBrands = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _selectedProductType;

  List<String> get brands => _filteredBrands;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setProductType(String productType) {
    _selectedProductType = productType;
    loadBrands();
  }

  Future<void> loadBrands() async {
    if (_selectedProductType == null) return;
    
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _brands = await FirebaseService.getBrandsByProductType(_selectedProductType!);
      _filteredBrands = _brands;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchBrands(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredBrands = _brands;
    } else {
      _filteredBrands = _brands
          .where((brand) => brand.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }}