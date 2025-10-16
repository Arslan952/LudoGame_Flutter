import 'package:flutter/material.dart';
import '../services/coin_service.dart';
import '../services/firestore_service.dart';

class CoinProvider extends ChangeNotifier {
  final CoinService _coinService = CoinService();
  final FirestoreService _firestoreService = FirestoreService();

  int _coins = 0;
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  int get coins => _coins;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> loadCoins(String userId) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      _coins = await _coinService.getPlayerCoins(userId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCoins(String userId, int amount, String reason) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      await _coinService.addCoins(userId, amount, reason);
      await loadCoins(userId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deductCoins(String userId, int amount, String reason) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      await _coinService.deductCoins(userId, amount, reason);
      await loadCoins(userId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool canAfford(int amount) {
    return _coins >= amount;
  }
}