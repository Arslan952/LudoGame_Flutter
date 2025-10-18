import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/coin_service.dart';

class ProfileProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final CoinService _coinService = CoinService();

  UserModel? _userProfile;
  bool _isLoading = false;
  bool _hasClaimedToday = false;
  String _errorMessage = '';

  // Getters
  UserModel? get userProfile => _userProfile;

  bool get isLoading => _isLoading;

  bool get hasClaimedToday => _hasClaimedToday;

  String get errorMessage => _errorMessage;

  Future<void> loadProfile(String uid) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      UserModel user = await _firestoreService.getUser(uid);
      _userProfile = user;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(String uid, String username) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      await _firestoreService.updateUser(uid, {'username': username});
      await loadProfile(uid);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> claimDailyReward(String uid) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      await _coinService.addCoins(uid, 10, 'Daily login reward');
      _hasClaimedToday = true;
      await loadProfile(uid);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<UserModel>> getLeaderboard() async {
    try {
      return await _firestoreService.getLeaderboard();
    } catch (e) {
      _errorMessage = e.toString();
      return [];
    }
  }
}
