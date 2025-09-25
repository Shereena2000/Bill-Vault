// lib/Service/firebase_auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get current user
  static User? get currentUser => _auth.currentUser;
  static bool get isLoggedIn => _auth.currentUser != null;
  
  // Auth state stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Sign Up with email and password
  static Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // Create user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = userCredential.user;
      if (user != null) {
        // Update display name
        await user.updateDisplayName(username);
        
        // Create user document in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'username': username,
          'displayName': username,
          'createdAt': FieldValue.serverTimestamp(),
          'isEmailVerified': false,
        });
        
        // Save login state
        await _saveLoginState(true);
        
        print('User signed up successfully: $username');
        return AuthResult.success(user);
      }
      
      return AuthResult.failure('Failed to create user');
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuth Sign Up Error: ${e.code} - ${e.message}');
      return AuthResult.failure(_getErrorMessage(e.code));
    } catch (e) {
      print('Sign Up Error: $e');
      return AuthResult.failure('An unexpected error occurred');
    }
  }
  
  // Sign In with email and password
  static Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = userCredential.user;
      if (user != null) {
        // Update last login
        await _firestore.collection('users').doc(user.uid).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
        
        // Save login state
        await _saveLoginState(true);
        
        print('User signed in successfully: ${user.email}');
        return AuthResult.success(user);
      }
      
      return AuthResult.failure('Failed to sign in');
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuth Sign In Error: ${e.code} - ${e.message}');
      return AuthResult.failure(_getErrorMessage(e.code));
    } catch (e) {
      print('Sign In Error: $e');
      return AuthResult.failure('An unexpected error occurred');
    }
  }
  
  // Sign Out
  static Future<bool> signOut() async {
    try {
      await _auth.signOut();
      await _saveLoginState(false);
      print('User signed out successfully');
      return true;
    } catch (e) {
      print('Sign Out Error: $e');
      return false;
    }
  }
  
  // Check if user is already logged in (for splash screen)
  static Future<bool> checkLoginStatus() async {
    try {
      // Check if user is authenticated with Firebase
      User? user = _auth.currentUser;
      if (user != null) {
        // Also check SharedPreferences for consistency
        SharedPreferences prefs = await SharedPreferences.getInstance();
        bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
        
        if (isLoggedIn) {
          print('User is already logged in: ${user.email}');
          return true;
        }
      }
      
      print('User is not logged in');
      return false;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }
  
  // Get user data from Firestore
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (doc.exists) {
          return doc.data() as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }
  
  // Update user profile (removed email update)
  static Future<bool> updateUserProfile({
    String? username,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        Map<String, dynamic> updates = {
          'updatedAt': FieldValue.serverTimestamp(),
        };
        
        if (username != null) {
          await user.updateDisplayName(username);
          updates['username'] = username;
          updates['displayName'] = username;
        }
        
        await _firestore.collection('users').doc(user.uid).update(updates);
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }
  
  // Send password reset email
  static Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('Password reset email sent to: $email');
      return true;
    } on FirebaseAuthException catch (e) {
      print('Password Reset Error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      print('Password Reset Error: $e');
      return false;
    }
  }
  
  // Delete user account
  static Future<bool> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Delete user document from Firestore
        await _firestore.collection('users').doc(user.uid).delete();
        
        // Delete Firebase Auth user
        await user.delete();
        
        // Clear login state
        await _saveLoginState(false);
        
        print('User account deleted successfully');
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting account: $e');
      return false;
    }
  }
  
  // Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }
  
  // Validate password strength
  static bool isValidPassword(String password) {
    // At least 6 characters
    return password.length >= 6;
  }
  
  // Save login state to SharedPreferences
  static Future<void> _saveLoginState(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }
  
  // Convert FirebaseAuth error codes to user-friendly messages
  static String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}

// Result class for authentication operations
class AuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final User? user;
  
  AuthResult._({
    required this.isSuccess,
    this.errorMessage,
    this.user,
  });
  
  factory AuthResult.success(User user) {
    return AuthResult._(
      isSuccess: true,
      user: user,
    );
  }
  
  factory AuthResult.failure(String errorMessage) {
    return AuthResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}