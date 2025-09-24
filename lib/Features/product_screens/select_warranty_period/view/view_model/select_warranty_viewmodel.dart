import 'package:flutter/material.dart';

class SelectWarrantyViewModel extends ChangeNotifier {
  final List<String> _warrantyPeriods = [
    "1 MONTH", "2 MONTHS", "3 MONTHS", "6 MONTHS", "1 Year", "18 MONTHS",
    "2 Years", "30 MONTHS", "3 Years", "4 Years", "5 Years", "6 Years",
    "7 Years", "8 Years", "9 Years", "10 Years"
  ];

  String? _selectedWarrantyPeriod;
  
  List<String> get warrantyPeriods => _warrantyPeriods;
  String? get selectedWarrantyPeriod => _selectedWarrantyPeriod;
  bool get hasSelection => _selectedWarrantyPeriod != null;

  void selectWarrantyPeriod(String period) {
    _selectedWarrantyPeriod = period;
    notifyListeners();
  }

  void clearSelection() {
    _selectedWarrantyPeriod = null;
    notifyListeners();
  }
}