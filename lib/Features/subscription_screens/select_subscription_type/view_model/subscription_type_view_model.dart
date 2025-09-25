
import 'package:flutter/material.dart';

import '../../../../Service/firebase_service.dart';
import '../../subscriptions/model/subscription_model.dart';

class SelectSubscriptionTypeViewModel extends ChangeNotifier {
  List<SubscriptionTypeModel> _subscriptionTypes = [];
  List<SubscriptionTypeModel> _filteredSubscriptionTypes = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  List<SubscriptionTypeModel> get subscriptionTypes => _filteredSubscriptionTypes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSubscriptionTypes() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Loading subscription types from Firebase...');
      
      // First, try to initialize default data if it doesn't exist
      await FirebaseService.initializeSubscriptionDefaultData();
      
      _subscriptionTypes = await FirebaseService.getSubscriptionTypes();
      _filteredSubscriptionTypes = _subscriptionTypes;
      
      print('Loaded ${_subscriptionTypes.length} subscription types');
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      print('Error loading subscription types: $e');
      notifyListeners();
    }
  }

  void searchSubscriptionTypes(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredSubscriptionTypes = _subscriptionTypes;
    } else {
      _filteredSubscriptionTypes = _subscriptionTypes
          .where((subscription) => subscription.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}