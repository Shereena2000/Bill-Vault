import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../Service/firebase_service.dart';
import '../../product/model/product_model.dart';

class PurchaseDetailViewModel extends ChangeNotifier {
  bool _showCalendar = false;
  DateTime _purchaseDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  File? _billImage;
  bool _isLoading = false;
  String? _error;

  // Product details from previous screens
  String? _productType;
  String? _productName;
  String? _brand;
  String? _warrantyPeriod;

  // Add instance tracking for debugging
  static int _instanceCount = 0;
  final int _instanceId = ++_instanceCount;

  PurchaseDetailViewModel() {
    print('PurchaseDetailViewModel instance #$_instanceId created');
  }

  @override
  void dispose() {
    print('PurchaseDetailViewModel instance #$_instanceId disposed');
    super.dispose();
  }

  // Getters
  bool get showCalendar => _showCalendar;
  DateTime get purchaseDate => _purchaseDate;
  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;
  File? get billImage => _billImage;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasBillImage => _billImage != null;

  // Add debug getters
  String? get productType => _productType;
  String? get productName => _productName;
  String? get brand => _brand;
  String? get warrantyPeriod => _warrantyPeriod;
  int get instanceId => _instanceId;

  String get formattedPurchaseDate => DateFormat('dd MMM, yyyy').format(_purchaseDate);

  void setProductDetails(String productType, String productName, String brand) {
    print('Instance #$_instanceId - Setting product details:');
    print('Product Type: $productType');
    print('Product Name: $productName');
    print('Brand: $brand');
    
    _productType = productType;
    _productName = productName;
    _brand = brand;
    
    print('Instance #$_instanceId - After setting:');
    print('_productType: $_productType');
    print('_productName: $_productName');
    print('_brand: $_brand');
    
    notifyListeners();
  }

  void setWarrantyPeriod(String warrantyPeriod) {
    print('Instance #$_instanceId - Setting warranty period: $warrantyPeriod');
    _warrantyPeriod = warrantyPeriod;
    print('Instance #$_instanceId - After setting _warrantyPeriod: $_warrantyPeriod');
    notifyListeners();
  }

  void toggleCalendar() {
    _showCalendar = !_showCalendar;
    _selectedDay = _purchaseDate;
    _focusedDay = _purchaseDate;
    notifyListeners();
  }

  void selectDate(DateTime selectedDate) {
    _selectedDay = selectedDate;
    _purchaseDate = selectedDate;
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

  Future<void> pickBillImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        _billImage = File(image.path);
        _error = null;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to pick image: $e';
      notifyListeners();
    }
  }

  Future<void> takeBillPhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        _billImage = File(image.path);
        _error = null;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to take photo: $e';
      notifyListeners();
    }
  }

  void removeBillImage() {
    _billImage = null;
    notifyListeners();
  }

  DateTime _calculateWarrantyEndDate() {
    if (_warrantyPeriod == null) return _purchaseDate;
    
    final period = _warrantyPeriod!.toLowerCase();
    if (period.contains('month')) {
      final months = int.tryParse(period.split(' ').first) ?? 12;
      return DateTime(_purchaseDate.year, _purchaseDate.month + months, _purchaseDate.day);
    } else if (period.contains('year')) {
      final years = int.tryParse(period.split(' ').first) ?? 1;
      return DateTime(_purchaseDate.year + years, _purchaseDate.month, _purchaseDate.day);
    }
    
    return DateTime(_purchaseDate.year + 1, _purchaseDate.month, _purchaseDate.day);
  }

  Future<bool> saveProduct() async {
    print('=== SAVE PRODUCT DEBUG (Instance #$_instanceId) ===');
    print('Product Type: $_productType');
    print('Product Name: $_productName');
    print('Brand: $_brand');
    print('Warranty Period: $_warrantyPeriod');
    
    if (_productType == null || _productName == null || _brand == null || _warrantyPeriod == null) {
      List<String> missingFields = [];
      if (_productType == null) missingFields.add('Product Type');
      if (_productName == null) missingFields.add('Product Name');
      if (_brand == null) missingFields.add('Brand');
      if (_warrantyPeriod == null) missingFields.add('Warranty Period');
      
      _error = 'Missing required information: ${missingFields.join(', ')}';
      print('Error: $_error');
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      String? billImageUrl;
      
      // Upload bill image if exists
      if (_billImage != null) {
        print('Uploading bill image...');
        billImageUrl = await FirebaseService.uploadBillImage(_billImage!, 'temp');
        print('Bill image uploaded: $billImageUrl');
      }

      final warrantyEndDate = _calculateWarrantyEndDate();
      final isWarrantyActive = warrantyEndDate.isAfter(DateTime.now());

      final product = ProductModel(
        productType: _productType!,
        productName: _productName!,
        brand: _brand!,
        purchaseDate: _purchaseDate,
        warrantyEndDate: warrantyEndDate,
        billImageUrl: billImageUrl,
        warrantyPeriod: _warrantyPeriod!,
        isWarrantyActive: isWarrantyActive,
      );

      print('Saving product to Firebase...');
      await FirebaseService.addProduct(product);
      print('Product saved successfully!');
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      print('Error saving product: $_error');
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    print('Instance #$_instanceId - Resetting all data');
    _showCalendar = false;
    _purchaseDate = DateTime.now();
    _focusedDay = DateTime.now();
    _selectedDay = null;
    _billImage = null;
    _isLoading = false;
    _error = null;
    _productType = null;
    _productName = null;
    _brand = null;
    _warrantyPeriod = null;
    notifyListeners();
  }

  // Debug method to check current state
  void debugCurrentState() {
    print('=== DEBUG CURRENT STATE (Instance #$_instanceId) ===');
    print('Product Type: $_productType');
    print('Product Name: $_productName');
    print('Brand: $_brand');
    print('Warranty Period: $_warrantyPeriod');
    print('Purchase Date: $_purchaseDate');
    print('Is Loading: $_isLoading');
    print('Error: $_error');
    print('================================================');
  }
}