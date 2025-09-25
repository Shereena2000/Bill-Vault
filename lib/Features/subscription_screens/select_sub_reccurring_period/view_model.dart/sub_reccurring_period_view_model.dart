
import 'dart:io';
import 'package:flutter/material.dart';

import '../../../../Service/firebase_service.dart';
import '../../subscriptions/model/subscription_data.dart';
import '../../subscriptions/model/subscription_model.dart';


class SelectSubscriptionRecurringPeriodViewModel extends ChangeNotifier {
  final List<String> _recurringPeriods = [
    "Monthly",
    "Quarterly", 
    "Half Yearly",
    "Yearly"
  ];

  String? _selectedRecurringPeriod;
  bool _isLoading = false;
  String? _error;
  
  List<String> get recurringPeriods => _recurringPeriods;
  String? get selectedRecurringPeriod => _selectedRecurringPeriod;
  bool get hasSelection => _selectedRecurringPeriod != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void selectRecurringPeriod(String period) {
    _selectedRecurringPeriod = period;
    notifyListeners();
  }

  void clearSelection() {
    _selectedRecurringPeriod = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  DateTime _calculateNextBillingDate(DateTime registrationDate, String recurringPeriod) {
    switch (recurringPeriod.toLowerCase()) {
      case 'monthly':
        return DateTime(registrationDate.year, registrationDate.month + 1, registrationDate.day);
      case 'quarterly':
        return DateTime(registrationDate.year, registrationDate.month + 3, registrationDate.day);
      case 'half yearly':
        return DateTime(registrationDate.year, registrationDate.month + 6, registrationDate.day);
      case 'yearly':
        return DateTime(registrationDate.year + 1, registrationDate.month, registrationDate.day);
      default:
        return DateTime(registrationDate.year, registrationDate.month + 1, registrationDate.day);
    }
  }

  Future<bool> saveSubscription(SubscriptionData subscriptionData) async {
    if (_selectedRecurringPeriod == null) {
      _error = 'Please select a recurring period';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final nextBillingDate = _calculateNextBillingDate(
        subscriptionData.registrationDate, 
        _selectedRecurringPeriod!
      );

      final subscription = SubscriptionModel(
        subscriptionType: subscriptionData.subscriptionType,
        subscriptionName: subscriptionData.subscriptionName,
        brand: subscriptionData.brand,
        registrationDate: subscriptionData.registrationDate,
        nextBillingDate: nextBillingDate,
        recurringPeriod: _selectedRecurringPeriod!,
        isActive: true,
      );

      print('Saving subscription to Firebase...');
      print('Subscription details:');
      print('- Type: ${subscription.subscriptionType}');
      print('- Name: ${subscription.subscriptionName}');
      print('- Brand: ${subscription.brand}');
      print('- Registration Date: ${subscription.registrationDate}');
      print('- Next Billing Date: ${subscription.nextBillingDate}');
      print('- Recurring Period: ${subscription.recurringPeriod}');
      
      await FirebaseService.addSubscription(subscription);
      print('Subscription saved successfully!');
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      print('Error saving subscription: $e');
      notifyListeners();
      return false;
    }
  }
}