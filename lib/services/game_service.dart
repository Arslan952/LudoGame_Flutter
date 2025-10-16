import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game_model.dart';

class GameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createGame({
    required List<String> playerIds,
    required List<String> playerNames,
    required int entryFee,
    required int numPlayers,
  }) async {
    try {
      List<int> colors = List.generate(numPlayers, (i) => i);
      Map<String, List<int>> tokenPositions = {};

      for (String playerId in playerIds) {
        tokenPositions[playerId] = [-1, -1, -1, -1];
      }

      DocumentReference gameRef = await _firestore.collection('games').add({
        'playerIds': playerIds,
        'playerNames': playerNames,
        'playerColors': colors,
        'currentTurnPlayerId': playerIds[0],
        'currentTurnDiceValue': 0,
        'tokenPositions': tokenPositions,
        'gameStatus': 'playing',
        'winnerId': null,
        'playerRanking': [],
        'entryFee': entryFee,
        'totalPrize': entryFee * playerIds.length,
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
        .map((doc) => GameModel.fromFirestore(doc));
  }

  Future<void> rollDice(String gameId, String playerId) async {
    try {
      int diceValue = _randomDice();
      await _firestore.collection('games').doc(gameId).update({
        'currentTurnDiceValue': diceValue,
      });
    } catch (e) {
      throw 'Failed to roll dice: $e';
    }
  }

  Future<void> moveToken(
      String gameId,
      String playerId,
      int tokenIndex,
      int newPosition,
      ) async {
    try {
      GameModel game = await getGame(gameId);
      Map<String, List<int>> tokenPositions = game.tokenPositions;

      tokenPositions[playerId]![tokenIndex] = newPosition;

      await _firestore.collection('games').doc(gameId).update({
        'tokenPositions': tokenPositions,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw 'Failed to move token: $e';
    }
  }

  Future<void> endTurn(String gameId, List<String> playerIds) async {
    try {
      GameModel game = await getGame(gameId);
      int currentIndex = playerIds.indexOf(game.currentTurnPlayerId);
      String nextPlayerId = playerIds[(currentIndex + 1) % playerIds.length];

      await _firestore.collection('games').doc(gameId).update({
        'currentTurnPlayerId': nextPlayerId,
        'currentTurnDiceValue': 0,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw 'Failed to end turn: $e';
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
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw 'Failed to complete game: $e';
    }
  }

  int _randomDice() => (DateTime.now().millisecondsSinceEpoch % 6) + 1;
}