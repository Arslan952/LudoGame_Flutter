import 'package:flutter/material.dart';
import '../models/game_model.dart';
import '../services/game_service.dart';
import '../utils/ludo_move_logic.dart';

class GameProvider extends ChangeNotifier {
  final GameService _gameService = GameService();

  GameModel? _currentGame;
  int _currentDiceValue = 0;
  bool _isRolling = false;
  bool _isLoading = false;
  String _errorMessage = '';
  List<int> _validMoves = [];

  GameModel? get currentGame => _currentGame;

  int get currentDiceValue => _currentDiceValue;

  bool get isRolling => _isRolling;

  bool get isLoading => _isLoading;

  String get errorMessage => _errorMessage;

  List<int> get validMoves => _validMoves;

  Future<void> createGame({
    required List<String> playerIds,
    required List<String> playerNames,
    required int entryFee,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      String gameId = await _gameService.createGame(
        playerIds: playerIds,
        playerNames: playerNames,
        entryFee: entryFee,
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
      notifyListeners();

      _currentGame = await _gameService.getGame(gameId);
      _currentDiceValue = _currentGame?.currentTurnDiceValue ?? 0;
      _updateValidMoves();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void streamGame(String gameId) {
    _gameService
        .streamGame(gameId)
        .listen(
          (game) {
            _currentGame = game;
            _currentDiceValue = game.currentTurnDiceValue;
            _updateValidMoves();
            notifyListeners();
          },
          onError: (e) {
            _errorMessage = e.toString();
            notifyListeners();
          },
        );
  }

  Future<void> rollDice(String gameId, String playerId) async {
    try {
      // Check if already rolling
      if (_isRolling) {
        debugPrint('DEBUG: Already rolling');
        return;
      }

      // Check if dice already rolled
      if (_currentGame?.diceRolled == true) {
        debugPrint('DEBUG: Dice already rolled');
        return;
      }

      // SET ROLLING TO TRUE FIRST - THIS UPDATES THE UI IMMEDIATELY
      _isRolling = true;
      notifyListeners(); // Notify UI that dice is rolling
      debugPrint('DEBUG: Set isRolling to true, notified listeners');

      // Simulate rolling for 600ms
      await Future.delayed(const Duration(milliseconds: 600));

      // Now call the service to roll
      int diceValue = await _gameService.rollDice(gameId);
      _currentDiceValue = diceValue;
      _updateValidMoves();

      debugPrint('DEBUG: Rolled dice: $diceValue');
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('DEBUG: Error rolling dice: $_errorMessage');
    } finally {
      // SET ROLLING TO FALSE AND NOTIFY
      _isRolling = false;
      notifyListeners(); // Notify UI that dice stopped rolling
      debugPrint('DEBUG: Set isRolling to false, notified listeners');
    }
  }

  Future<bool> moveToken(String gameId, int tokenIndex, String playerId) async {
    try {
      if (_currentGame == null || !_validMoves.contains(tokenIndex)) {
        return false;
      }

      int currentPos =
          _currentGame!.tokenPositions[playerId]?[tokenIndex] ?? -1;
      int newPos = LudoMoveLogic.moveToken(
        currentPos,
        _currentDiceValue,
        _currentGame!.playerColors[_currentGame!.playerIds.indexOf(playerId)],
      );

      await _gameService.moveToken(gameId, tokenIndex, newPos, playerId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  Future<void> nextTurn(String gameId) async {
    try {
      await _gameService.nextTurn(gameId);
      await Future.delayed(const Duration(milliseconds: 500));
      _currentDiceValue = 0;
      _validMoves = [];
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void _updateValidMoves() {
    if (_currentGame == null) {
      _validMoves = [];
      return;
    }

    String currentPlayerId = _currentGame!.currentPlayerId;
    List<int> tokenPositions =
        _currentGame!.tokenPositions[currentPlayerId] ?? [];

    _validMoves = [];
    for (int i = 0; i < tokenPositions.length; i++) {
      if (LudoMoveLogic.canMoveToken(
        tokenPositions[i],
        _currentDiceValue,
        _currentGame!.playerColors[_currentGame!.currentTurnIndex],
      )) {
        _validMoves.add(i);
      }
    }
  }

  Future<void> completeGame(
    String gameId,
    String winnerId,
    List<String> ranking,
  ) async {
    try {
      await _gameService.completeGame(gameId, winnerId, ranking);
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  void resetGame() {
    _currentGame = null;
    _currentDiceValue = 0;
    _isRolling = false;
    _validMoves = [];
    _errorMessage = '';
    notifyListeners();
  }
}
