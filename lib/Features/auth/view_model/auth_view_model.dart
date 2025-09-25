import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../Service/firebase_auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  User? _currentUser;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  
  // Text controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  AuthViewModel() {
    _initializeAuth();
  }
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isPasswordVisible => _isPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;
  
  // Initialize authentication state
  void _initializeAuth() {
    try {
      // Safely get current user
      _currentUser = FirebaseAuthService.currentUser;
      
      // Listen to auth state changes with error handling
      _listenToAuthChanges();
    } catch (e) {
      print('Error initializing AuthViewModel: $e');
      _setError('Authentication service unavailable');
    }
  }
  
  // Listen to auth state changes
  void _listenToAuthChanges() {
    try {
      FirebaseAuthService.authStateChanges.listen(
        (User? user) {
          _currentUser = user;
          notifyListeners();
        },
        onError: (error) {
          print('Auth state change error: $error');
          _setError('Authentication error occurred');
        },
      );
    } catch (e) {
      print('Error setting up auth listener: $e');
    }
  }
  
  // Toggle password visibility
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }
  
  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }
  
  // Sign Up
  Future<bool> signUp() async {
    if (!_validateSignUpForm()) return false;
    
    try {
      _setLoading(true);
      _clearError();
      
      final AuthResult result = await FirebaseAuthService.signUpWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text,
        username: usernameController.text.trim(),
      );
      
      if (result.isSuccess) {
        _currentUser = result.user;
        _clearForm();
        _setLoading(false);
        return true;
      } else {
        _setError(result.errorMessage ?? 'Sign up failed. Please try again.');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      print('Sign Up Error: $e');
      _setError('An unexpected error occurred during sign up');
      _setLoading(false);
      return false;
    }
  }
  
  // Sign In
  Future<bool> signIn() async {
    if (!_validateSignInForm()) return false;
    
    try {
      _setLoading(true);
      _clearError();
      
      final String email = emailController.text.trim();
      
      final AuthResult result = await FirebaseAuthService.signInWithEmail(
        email: email,
        password: passwordController.text,
      );
      
      if (result.isSuccess) {
        _currentUser = result.user;
        _clearForm();
        _setLoading(false);
        return true;
      } else {
        _setError(result.errorMessage ?? 'Sign in failed. Please try again.');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      print('Sign In Error: $e');
      _setError('An unexpected error occurred during sign in');
      _setLoading(false);
      return false;
    }
  }
  
  // Sign Out
  Future<bool> signOut() async {
    try {
      _setLoading(true);
      _clearError();
      
      final bool success = await FirebaseAuthService.signOut();
      
      if (success) {
        _currentUser = null;
        _clearForm();
        _setLoading(false);
        return true;
      } else {
        _setError('Failed to sign out. Please try again.');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      print('Sign Out Error: $e');
      _setError('An error occurred while signing out');
      _setLoading(false);
      return false;
    }
  }
  
  // Check login status (for splash screen)
  Future<bool> checkLoginStatus() async {
    try {
      _setLoading(true);
      _clearError();
      
      final bool isLoggedIn = await FirebaseAuthService.checkLoginStatus();
      
      if (isLoggedIn) {
        _currentUser = FirebaseAuthService.currentUser;
      } else {
        _currentUser = null;
      }
      
      _setLoading(false);
      return isLoggedIn;
    } catch (e) {
      print('Check Login Status Error: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    if (email.isEmpty) {
      _setError('Please enter your email address');
      return false;
    }
    
    if (!FirebaseAuthService.isValidEmail(email)) {
      _setError('Please enter a valid email address');
      return false;
    }
    
    try {
      _setLoading(true);
      _clearError();
      
      final bool success = await FirebaseAuthService.sendPasswordResetEmail(email);
      
      _setLoading(false);
      
      if (success) {
        return true;
      } else {
        _setError('Failed to send password reset email. Please try again.');
        return false;
      }
    } catch (e) {
      print('Password Reset Error: $e');
      _setError('An error occurred while sending reset email');
      _setLoading(false);
      return false;
    }
  }
  
  // Validate sign up form
  bool _validateSignUpForm() {
    final String username = usernameController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text;
    final String confirmPassword = confirmPasswordController.text;
    
    // Validate username
    if (username.isEmpty) {
      _setError('Please enter a username');
      return false;
    }
    
    if (username.length < 3) {
      _setError('Username must be at least 3 characters long');
      return false;
    }
    
    // Validate email
    if (email.isEmpty) {
      _setError('Please enter an email address');
      return false;
    }
    
    if (!FirebaseAuthService.isValidEmail(email)) {
      _setError('Please enter a valid email address');
      return false;
    }
    
    // Validate password
    if (password.isEmpty) {
      _setError('Please enter a password');
      return false;
    }
    
    if (!FirebaseAuthService.isValidPassword(password)) {
      _setError('Password must be at least 6 characters long');
      return false;
    }
    
    // Validate confirm password
    if (confirmPassword.isEmpty) {
      _setError('Please confirm your password');
      return false;
    }
    
    if (password != confirmPassword) {
      _setError('Passwords do not match');
      return false;
    }
    
    return true;
  }
  
  // Validate sign in form
  bool _validateSignInForm() {
    final String email = emailController.text.trim();
    final String password = passwordController.text;
    
    // Validate email
    if (email.isEmpty) {
      _setError('Please enter your email address');
      return false;
    }
    
    if (!FirebaseAuthService.isValidEmail(email)) {
      _setError('Please enter a valid email address');
      return false;
    }
    
    // Validate password
    if (password.isEmpty) {
      _setError('Please enter your password');
      return false;
    }
    
    return true;
  }
  
  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      return await FirebaseAuthService.getUserData();
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }
  
  // Update user profile
  Future<bool> updateUserProfile({String? username}) async {
    try {
      _setLoading(true);
      _clearError();
      
      final bool success = await FirebaseAuthService.updateUserProfile(
        username: username,
      );
      
      _setLoading(false);
      
      if (success) {
        return true;
      } else {
        _setError('Failed to update profile');
        return false;
      }
    } catch (e) {
      print('Update Profile Error: $e');
      _setError('An error occurred while updating profile');
      _setLoading(false);
      return false;
    }
  }
  
  // Delete user account
  Future<bool> deleteAccount() async {
    try {
      _setLoading(true);
      _clearError();
      
      final bool success = await FirebaseAuthService.deleteAccount();
      
      if (success) {
        _currentUser = null;
        _clearForm();
        _setLoading(false);
        return true;
      } else {
        _setError('Failed to delete account. Please try again.');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      print('Delete Account Error: $e');
      _setError('An error occurred while deleting account');
      _setLoading(false);
      return false;
    }
  }
  
  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
    notifyListeners();
  }
  
  void _clearForm() {
    usernameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    _isPasswordVisible = false;
    _isConfirmPasswordVisible = false;
    _clearError();
  }
  
  // Public method to clear error
  void clearError() {
    _clearError();
  }
  
  // Dispose method
  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}