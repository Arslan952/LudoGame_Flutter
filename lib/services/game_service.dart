import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game_model.dart';
import '../utils/ludo_move_logic.dart';

class GameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createGame({
    required List<String> playerIds,
    required List<String> playerNames,
    required int entryFee,
  }) async {
    try {
      int numPlayers = playerIds.length;
      List<int> colors = List.generate(numPlayers, (i) => i);
      Map<String, List<int>> tokenPositions = {};

      for (String playerId in playerIds) {
        tokenPositions[playerId] = [-1, -1, -1, -1];
      }

      DocumentReference gameRef = await _firestore.collection('games').add({
        'playerIds': playerIds,
        'playerNames': playerNames,
        'playerColors': colors,
        'currentTurnIndex': 0,
        'currentTurnDiceValue': 0,
        'diceRolled': false,
        'selectedTokenIndex': null,
        'tokenPositions': tokenPositions,
        'gameStatus': 'playing',
        'winnerId': null,
        'playerRanking': [],
        'entryFee': entryFee,
        'totalPrize': entryFee * numPlayers,
        'doubleCount': 0,
        'gameEnded': false,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      return gameRef.id;
    } catch (e) {
      throw 'Failed to create game: $e';
    }
  }

  Future<GameModel> getGame(String gameId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('games').doc(gameId).get();
      if (!doc.exists) throw 'Game not found';
      return GameModel.fromFirestore(doc);
    } catch (e) {
      throw 'Failed to fetch game: $e';
    }
  }

  Stream<GameModel> streamGame(String gameId) {
    return _firestore
        .collection('games')
        .doc(gameId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) throw 'Game not found';
      return GameModel.fromFirestore(doc);
    });
  }

  Future<int> rollDice(String gameId) async {
    try {
      int diceValue = (DateTime.now().millisecondsSinceEpoch % 6) + 1;

      await _firestore.collection('games').doc(gameId).update({
        'currentTurnDiceValue': diceValue,
        'diceRolled': true,
        'updatedAt': Timestamp.now(),
      });

      return diceValue;
    } catch (e) {
      throw 'Failed to roll dice: $e';
    }
  }

  Future<void> moveToken(
      String gameId,
      int tokenIndex,
      int newPosition,
      String playerId,
      ) async {
    try {
      GameModel game = await getGame(gameId);
      Map<String, List<int>> positions = game.tokenPositions;

      positions[playerId]![tokenIndex] = newPosition;

      await _firestore.collection('games').doc(gameId).update({
        'tokenPositions': positions,
        'selectedTokenIndex': tokenIndex,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw 'Failed to move token: $e';
    }
  }

  Future<void> nextTurn(String gameId) async {
    try {
      GameModel game = await getGame(gameId);
      int nextTurnIndex = (game.currentTurnIndex + 1) % game.playerIds.length;

      await _firestore.collection('games').doc(gameId).update({
        'currentTurnIndex': nextTurnIndex,
        'currentTurnDiceValue': 0,
        'diceRolled': false,
        'selectedTokenIndex': null,
        'doubleCount': 0,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw 'Failed to change turn: $e';
    }
  }

  Future<void> completeGame(
      String gameId,
      String winnerId,
      List<String> ranking,
      ) async {
    try {
      await _firestore.collection('games').doc(gameId).update({
        'gameStatus': 'completed',
        'winnerId': winnerId,
        'playerRanking': ranking,
        'gameEnded': true,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw 'Failed to complete game: $e';
    }
  }

  Future<void> resetDiceAndToken(String gameId) async {
    try {
      await _firestore.collection('games').doc(gameId).update({
        'diceRolled': false,
        'currentTurnDiceValue': 0,
        'selectedTokenIndex': null,
      });
    } catch (e) {
      throw 'Failed to reset: $e';
    }
  }
}