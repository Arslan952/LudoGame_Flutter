import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? _currentUser;
  UserModel? _userModel;
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  User? get currentUser => _currentUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  AuthProvider() {
    _currentUser = _authService.getCurrentUser();
    if (_currentUser != null) {
      loadUserData();
    }
  }

  Future<void> signUp(String email, String password, String username) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      User? user = await _authService.signUpWithEmail(email, password, username);

      if (user != null) {
        _currentUser = user;
        await loadUserData();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      User? user = await _authService.signInWithEmail(email, password);

      if (user != null) {
        _currentUser = user;
        await loadUserData();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.signOut();
      _currentUser = null;
      _userModel = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserData() async {
    try {
      if (_currentUser != null) {
        UserModel user = await _firestoreService.getUser(_currentUser!.uid);
        _userModel = user;
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.resetPassword(email);
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserProfile(String username) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_currentUser != null) {
        await _firestoreService.updateUser(_currentUser!.uid, {
          'username': username,
        });
        await loadUserData();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}