
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../Service/firebase_service.dart';
import '../model/contact_model.dart';

class ContactViewModel extends ChangeNotifier {
  List<ContactModel> _contacts = [];
  List<ContactModel> _filteredContacts = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  StreamSubscription? _contactsSubscription;

  // Getters
  List<ContactModel> get contacts => _filteredContacts;
  List<ContactModel> get allContacts => _contacts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasContacts => _contacts.isNotEmpty;
  String get searchQuery => _searchQuery;

  // Get available professions
  List<String> get availableProfessions => FirebaseService.getAvailableProfessions();

  // Start listening to contacts stream
  void startListening() {
    print('ContactViewModel - Starting to listen for contacts');
    _contactsSubscription?.cancel();
    
    _contactsSubscription = FirebaseService.getContactsStream().listen(
      (contacts) {
        print('ContactViewModel - Received ${contacts.length} contacts from stream');
        _contacts = contacts;
        _applySearchFilter();
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        print('ContactViewModel - Stream error: $error');
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Add new contact
  Future<bool> addContact({
    required String name,
    required String phone,
    required String profession,
  }) async {
    if (name.trim().isEmpty || phone.trim().isEmpty || profession.trim().isEmpty) {
      _error = 'All fields are required';
      notifyListeners();
      return false;
    }

    // Basic phone validation
    if (!_isValidPhone(phone)) {
      _error = 'Please enter a valid phone number';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final contact = ContactModel(
        name: name.trim(),
        phone: phone.trim(),
        profession: profession.trim(),
      );

      await FirebaseService.addContact(contact);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      print('Error adding contact: $e');
      notifyListeners();
      return false;
    }
  }

  // Update contact
  Future<bool> updateContact({
    required String id,
    required String name,
    required String phone,
    required String profession,
  }) async {
    if (name.trim().isEmpty || phone.trim().isEmpty || profession.trim().isEmpty) {
      _error = 'All fields are required';
      notifyListeners();
      return false;
    }

    if (!_isValidPhone(phone)) {
      _error = 'Please enter a valid phone number';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Find the existing contact
      final existingContact = _contacts.firstWhere((contact) => contact.id == id);
      
      final updatedContact = existingContact.copyWith(
        name: name.trim(),
        phone: phone.trim(),
        profession: profession.trim(),
      );

      await FirebaseService.updateContact(updatedContact);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      print('Error updating contact: $e');
      notifyListeners();
      return false;
    }
  }

  // Delete contact
  Future<bool> deleteContact(String contactId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await FirebaseService.deleteContact(contactId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      print('Error deleting contact: $e');
      notifyListeners();
      return false;
    }
  }

  // Search contacts
  void searchContacts(String query) {
    _searchQuery = query;
    _applySearchFilter();
    notifyListeners();
  }

  // Apply search filter
  void _applySearchFilter() {
    if (_searchQuery.isEmpty) {
      _filteredContacts = _contacts;
    } else {
      _filteredContacts = _contacts.where((contact) {
        return contact.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               contact.phone.contains(_searchQuery) ||
               contact.profession.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  // Get contacts by profession
  Future<List<ContactModel>> getContactsByProfession(String profession) async {
    try {
      return await FirebaseService.getContactsByProfession(profession);
    } catch (e) {
      print('Error getting contacts by profession: $e');
      return [];
    }
  }

  // Validate phone number (basic validation)
  bool _isValidPhone(String phone) {
    // Remove any non-digit characters for validation
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    // Check if it has 10 digits (Indian standard)
    return cleanPhone.length == 10 && RegExp(r'^[0-9]+$').hasMatch(cleanPhone);
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    _applySearchFilter();
    notifyListeners();
  }

  // Get contact by ID
  ContactModel? getContactById(String id) {
    try {
      return _contacts.firstWhere((contact) => contact.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _contactsSubscription?.cancel();
    super.dispose();
  }
}