
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SubscriptionRegistrationDateViewModel extends ChangeNotifier {
  bool _showCalendar = false;
  DateTime _registrationDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = false;
  String? _error;

  // Subscription details from previous screens
  String? _subscriptionType;
  String? _subscriptionName;
  String? _brand;

  // Getters
  bool get showCalendar => _showCalendar;
  DateTime get registrationDate => _registrationDate;
  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get subscriptionType => _subscriptionType;
  String? get subscriptionName => _subscriptionName;
  String? get brand => _brand;

  String get formattedRegistrationDate => DateFormat('dd MMM, yyyy').format(_registrationDate);

  void setSubscriptionDetails(String subscriptionType, String subscriptionName, String brand) {
    print('Setting subscription details:');
    print('Subscription Type: $subscriptionType');
    print('Subscription Name: $subscriptionName');
    print('Brand: $brand');
    
    _subscriptionType = subscriptionType;
    _subscriptionName = subscriptionName;
    _brand = brand;
    notifyListeners();
  }

  void toggleCalendar() {
    _showCalendar = !_showCalendar;
    _selectedDay = _registrationDate;
    _focusedDay = _registrationDate;
    notifyListeners();
  }

  void selectDate(DateTime selectedDate) {
    _selectedDay = selectedDate;
    _registrationDate = selectedDate;
    _showCalendar = false;
    notifyListeners();
  }

  void hideCalendar() {
    _showCalendar = false;
    notifyListeners();
  }

  void onPageChanged(DateTime focusedDay) {
    _focusedDay = focusedDay;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _showCalendar = false;
    _registrationDate = DateTime.now();
    _focusedDay = DateTime.now();
    _selectedDay = null;
    _isLoading = false;
    _error = null;
    _subscriptionType = null;
    _subscriptionName = null;
    _brand = null;
    notifyListeners();
  }

  // Debug method to check current state
  void debugCurrentState() {
    print('=== DEBUG SUBSCRIPTION REGISTRATION STATE ===');
    print('Subscription Type: $_subscriptionType');
    print('Subscription Name: $_subscriptionName');
    print('Brand: $_brand');
    print('Registration Date: $_registrationDate');
    print('Is Loading: $_isLoading');
    print('Error: $_error');
    print('==============================================');
  }
}