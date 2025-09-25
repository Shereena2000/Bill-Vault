
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../Service/firebase_service.dart';
import '../model/subscription_model.dart';

class SubscriptionViewModel extends ChangeNotifier {
  List<SubscriptionModel> _subscriptions = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _subscriptionsSubscription;

  List<SubscriptionModel> get subscriptions => _subscriptions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasSubscriptions => _subscriptions.isNotEmpty;

  void startListening() {
    print('SubscriptionViewModel - Starting to listen for subscriptions');
    _subscriptionsSubscription?.cancel();
    _subscriptionsSubscription = FirebaseService.getSubscriptionsStream().listen(
      (subscriptions) {
        print('SubscriptionViewModel - Received ${subscriptions.length} subscriptions');
        _subscriptions = subscriptions;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        print('SubscriptionViewModel - Stream error: $error');
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscriptionsSubscription?.cancel();
    super.dispose();
  }

  Future<void> deleteSubscription(String subscriptionId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await FirebaseService.deleteSubscription(subscriptionId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      print('Error deleting subscription: $e');
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}