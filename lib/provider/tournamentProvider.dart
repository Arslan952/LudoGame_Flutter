import 'package:flutter/material.dart';
import '../models/tournament_model.dart';
import '../services/tournament_service.dart';
import '../services/coin_service.dart';

class TournamentProvider extends ChangeNotifier {
  final TournamentService _tournamentService = TournamentService();
  final CoinService _coinService = CoinService();

  List<TournamentModel> _tournaments = [];
  TournamentModel? _currentTournament;
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  List<TournamentModel> get tournaments => _tournaments;
  TournamentModel? get currentTournament => _currentTournament;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> loadTournaments() async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      List<TournamentModel> result = await _tournamentService.getTournaments();
      _tournaments = result;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTournament(
      String name,
      int maxPlayers,
      int entryFee,
      List<int> prizePool,
      ) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      await _tournamentService.createTournament(
        name,
        maxPlayers,
        entryFee,
        prizePool,
      );

      await loadTournaments();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> joinTournament(String tournamentId, int entryFee, String userId) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      await _coinService.deductCoins(userId, entryFee, 'Tournament entry fee');
      await _tournamentService.joinTournament(tournamentId);

      await loadTournaments();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTournament(String tournamentId) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      TournamentModel tournament = await _tournamentService.getTournament(tournamentId);
      _currentTournament = tournament;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}