// lib/services/app_auth_provider.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';
import 'inventory_service.dart';
import 'recipe_service.dart';

class AppAuthProvider with ChangeNotifier {
  final AuthService _authService;

  User? _user;
  bool _isLoading = true;        // start in loading state
  String? _errorMessage;

  AppAuthProvider(FirebaseAuth firebaseAuth)
      : _authService = AuthService(firebaseAuth) {
    // Start with no user to force landing screen on fresh launch
    _user = null;
    _isLoading = false;
    
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      _isLoading = false;        // stop loading on first event
      notifyListeners();
    }, onError: (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSignedIn => _user != null;

  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result != null) {
        _user = result.user;
        notifyListeners();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'An unknown error occurred');
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Create account with email and password
  Future<bool> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (result != null) {
        _user = result.user;
        notifyListeners();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'An unknown error occurred');
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _authService.signInWithGoogle();

      if (result != null) {
        _user = result.user;
        notifyListeners();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'Google Sign-In failed');
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      _clearError();

      // Clear local data before signing out
      await Future.wait([
        InventoryService.clearInventory(),
        RecipeService.clearRecipes(),
      ]);

      await _authService.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail({required String email}) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'Failed to send reset email');
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Helpers
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
