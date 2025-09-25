
import 'package:flutter/material.dart';

import '../../../../Service/firebase_service.dart';

class SelectSubscriptionBrandViewModel extends ChangeNotifier {
  List<String> _brands = [];
  List<String> _filteredBrands = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _selectedSubscriptionType;

  List<String> get brands => _filteredBrands;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setSubscriptionType(String subscriptionType) {
    print('Setting subscription type: $subscriptionType');
    _selectedSubscriptionType = subscriptionType;
    loadBrands();
  }

  Future<void> loadBrands() async {
    if (_selectedSubscriptionType == null) {
      print('No subscription type set, cannot load brands');
      return;
    }
    
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Loading brands for subscription type: $_selectedSubscriptionType');
      _brands = await FirebaseService.getSubscriptionBrandsByType(_selectedSubscriptionType!);
      _filteredBrands = _brands;
      
      print('Loaded ${_brands.length} brands: $_brands');
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      print('Error loading brands: $e');
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
  }
}