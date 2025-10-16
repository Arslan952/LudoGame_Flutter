import 'package:cloud_firestore/cloud_firestore.dart';

class MatchmakingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addPlayerToQueue(
      String playerId,
      String playerName,
      int numPlayers,
      int entryFee,
      ) async {
    try {
      await _firestore.collection('matchmaking_queue').add({
        'playerId': playerId,
        'playerName': playerName,
        'numPlayers': numPlayers,
        'entryFee': entryFee,
        'joinedAt': Timestamp.now(),
        'matched': false,
      });
    } catch (e) {
      throw 'Failed to join queue: $e';
    }
  }

  Stream<DocumentSnapshot> watchMatchmakingStatus(String playerId) {
    return _firestore
        .collection('matchmaking_queue')
        .where('playerId', isEqualTo: playerId)
        .limit(1)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty ? snapshot.docs.first : null as DocumentSnapshot)
        .where((event) => event != null);
  }

  Future<void> removePlayerFromQueue(String playerId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('matchmaking_queue')
          .where('playerId', isEqualTo: playerId)
          .get();

      for (DocumentSnapshot doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw 'Failed to remove from queue: $e';
    }
  }
}