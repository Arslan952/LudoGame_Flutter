import 'package:cloud_firestore/cloud_firestore.dart';

class GameModel {
  final String gameId;
  final List<String> playerIds;
  final List<String> playerNames;
  final List<int> playerColors; // 0: Red, 1: Green, 2: Yellow, 3: Blue
  final String currentTurnPlayerId;
  final int currentTurnDiceValue;
  final Map<String, List<int>> tokenPositions;
  final String gameStatus; // 'waiting', 'playing', 'completed'
  final String? winnerId;
  final List<String> playerRanking;
  final int entryFee;
  final int totalPrize;
  final DateTime createdAt;
  final DateTime updatedAt;

  GameModel({
    required this.gameId,
    required this.playerIds,
    required this.playerNames,
    required this.playerColors,
    required this.currentTurnPlayerId,
    required this.currentTurnDiceValue,
    required this.tokenPositions,
    required this.gameStatus,
    this.winnerId,
    required this.playerRanking,
    required this.entryFee,
    required this.totalPrize,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GameModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GameModel(
      gameId: doc.id,
      playerIds: List<String>.from(data['playerIds'] ?? []),
      playerNames: List<String>.from(data['playerNames'] ?? []),
      playerColors: List<int>.from(data['playerColors'] ?? []),
      currentTurnPlayerId: data['currentTurnPlayerId'] ?? '',
      currentTurnDiceValue: data['currentTurnDiceValue'] ?? 0,
      tokenPositions: Map<String, List<int>>.from(
          (data['tokenPositions'] as Map).map(
                  (k, v) => MapEntry(k, List<int>.from(v))
          )
      ),
      gameStatus: data['gameStatus'] ?? 'waiting',
      winnerId: data['winnerId'],
      playerRanking: List<String>.from(data['playerRanking'] ?? []),
      entryFee: data['entryFee'] ?? 0,
      totalPrize: data['totalPrize'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'playerIds': playerIds,
    'playerNames': playerNames,
    'playerColors': playerColors,
    'currentTurnPlayerId': currentTurnPlayerId,
    'currentTurnDiceValue': currentTurnDiceValue,
    'tokenPositions': tokenPositions,
    'gameStatus': gameStatus,
    'winnerId': winnerId,
    'playerRanking': playerRanking,
    'entryFee': entryFee,
    'totalPrize': totalPrize,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}