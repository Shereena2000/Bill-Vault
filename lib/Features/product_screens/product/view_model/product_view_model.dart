import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../Service/firebase_service.dart';
import '../model/product_model.dart';

class ProductViewModel extends ChangeNotifier {
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _productsSubscription;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProducts => _products.isNotEmpty;

  void startListening() {
    _productsSubscription?.cancel();
    _productsSubscription = FirebaseService.getProductsStream().listen(
      (products) {
        _products = products;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _productsSubscription?.cancel();
    super.dispose();
  }

  Future<void> deleteProduct(String productId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await FirebaseService.deleteProduct(productId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}