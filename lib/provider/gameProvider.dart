import 'package:flutter/material.dart';
import '../models/game_model.dart';
import '../services/game_service.dart';
import '../services/coin_service.dart';
import '../utils/ludo_game_logic.dart';

class GameProvider extends ChangeNotifier {
  final GameService _gameService = GameService();
  final CoinService _coinService = CoinService();

  GameModel? _currentGame;
  int _currentDiceValue = 0;
  bool _isMyTurn = false;
  List<int> _validMoves = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  GameModel? get currentGame => _currentGame;
  int get currentDiceValue => _currentDiceValue;
  bool get isMyTurn => _isMyTurn;
  List<int> get validMoves => _validMoves;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> createGame({
    required List<String> playerIds,
    required List<String> playerNames,
    required int entryFee,
    required int numPlayers,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      String gameId = await _gameService.createGame(
        playerIds: playerIds,
        playerNames: playerNames,
        entryFee: entryFee,
        numPlayers: numPlayers,
      );

      await loadGame(gameId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadGame(String gameId) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      GameModel game = await _gameService.getGame(gameId);
      _currentGame = game;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void streamGame(String gameId) {
    _gameService.streamGame(gameId).listen((game) {
      _currentGame = game;
      notifyListeners();
    });
  }

  Future<void> rollDice(String gameId, String playerId) async {
    try {
      await _gameService.rollDice(gameId, playerId);
      await Future.delayed(const Duration(milliseconds: 500));

      if (_currentGame != null) {
        _currentDiceValue = _currentGame!.currentTurnDiceValue;
        _updateValidMoves();
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> moveToken(
      String gameId,
      String playerId,
      int tokenIndex,
      int newPosition,
      ) async {
    try {
      await _gameService.moveToken(gameId, playerId, tokenIndex, newPosition);
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  void _updateValidMoves() {
    if (_currentGame == null) return;
    _validMoves.clear();
  }

  Future<void> endTurn(String gameId, List<String> playerIds) async {
    try {
      await _gameService.endTurn(gameId, playerIds);
      _currentDiceValue = 0;
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> completeGame(
      String gameId,
      String winnerId,
      List<String> ranking,
      int entryFee,
      String currentUserId,
      ) async {
    try {
      await _gameService.completeGame(gameId, winnerId, ranking);

      int winnings = LudoGameLogic.calculateWinnings(entryFee, ranking.length, 1);
      if (winnerId == currentUserId) {
        await _coinService.addCoins(winnerId, winnings, 'Game won');
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  void resetGame() {
    _currentGame = null;
    _currentDiceValue = 0;
    _isMyTurn = false;
    _validMoves = [];
    _errorMessage = '';
    notifyListeners();
  }
}