import 'package:cloud_firestore/cloud_firestore.dart';

class GameModel {
  final String gameId;
  final List<String> playerIds;
  final List<String> playerNames;
  final List<int> playerColors;
  final int currentTurnIndex;
  final int currentTurnDiceValue;
  final bool diceRolled;
  final int? selectedTokenIndex;
  final Map<String, List<int>> tokenPositions;
  final String gameStatus;
  final String? winnerId;
  final List<String> playerRanking;
  final int entryFee;
  final int totalPrize;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int doubleCount;
  final bool gameEnded;

  GameModel({
    required this.gameId,
    required this.playerIds,
    required this.playerNames,
    required this.playerColors,
    required this.currentTurnIndex,
    required this.currentTurnDiceValue,
    required this.diceRolled,
    this.selectedTokenIndex,
    required this.tokenPositions,
    required this.gameStatus,
    this.winnerId,
    required this.playerRanking,
    required this.entryFee,
    required this.totalPrize,
    required this.createdAt,
    required this.updatedAt,
    required this.doubleCount,
    required this.gameEnded,
  });

  String get currentPlayerId => playerIds[currentTurnIndex];

  factory GameModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GameModel(
      gameId: doc.id,
      playerIds: List<String>.from(data['playerIds'] ?? []),
      playerNames: List<String>.from(data['playerNames'] ?? []),
      playerColors: List<int>.from(data['playerColors'] ?? []),
      currentTurnIndex: data['currentTurnIndex'] ?? 0,
      currentTurnDiceValue: data['currentTurnDiceValue'] ?? 0,
      diceRolled: data['diceRolled'] ?? false,
      selectedTokenIndex: data['selectedTokenIndex'],
      tokenPositions: Map<String, List<int>>.from(
        (data['tokenPositions'] as Map? ?? {}).map(
              (k, v) => MapEntry(k, List<int>.from(v ?? [])),
        ),
      ),
      gameStatus: data['gameStatus'] ?? 'playing',
      winnerId: data['winnerId'],
      playerRanking: List<String>.from(data['playerRanking'] ?? []),
      entryFee: data['entryFee'] ?? 0,
      totalPrize: data['totalPrize'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      doubleCount: data['doubleCount'] ?? 0,
      gameEnded: data['gameEnded'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'playerIds': playerIds,
    'playerNames': playerNames,
    'playerColors': playerColors,
    'currentTurnIndex': currentTurnIndex,
    'currentTurnDiceValue': currentTurnDiceValue,
    'diceRolled': diceRolled,
    'selectedTokenIndex': selectedTokenIndex,
    'tokenPositions': tokenPositions,
    'gameStatus': gameStatus,
    'winnerId': winnerId,
    'playerRanking': playerRanking,
    'entryFee': entryFee,
    'totalPrize': totalPrize,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
    'doubleCount': doubleCount,
    'gameEnded': gameEnded,
  };
}