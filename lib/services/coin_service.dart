import 'package:cloud_firestore/cloud_firestore.dart';

class CoinService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> deductCoins(String playerId, int amount, String reason) async {
    try {
      await _firestore.runTransaction((transaction) async {
        DocumentReference userRef = _firestore.collection('users').doc(playerId);
        DocumentSnapshot snapshot = await transaction.get(userRef);

        int currentCoins = snapshot['coins'] ?? 0;

        if (currentCoins < amount) {
          throw 'Insufficient coins';
        }

        transaction.update(userRef, {
          'coins': currentCoins - amount,
        });

        await _firestore.collection('coin_transactions').add({
          'playerId': playerId,
          'amount': -amount,
          'reason': reason,
          'timestamp': Timestamp.now(),
          'balanceBefore': currentCoins,
          'balanceAfter': currentCoins - amount,
        });
      });
    } catch (e) {
      throw 'Failed to deduct coins: $e';
    }
  }

  Future<void> addCoins(String playerId, int amount, String reason) async {
    try {
      await _firestore.runTransaction((transaction) async {
        DocumentReference userRef = _firestore.collection('users').doc(playerId);
        DocumentSnapshot snapshot = await transaction.get(userRef);

        int currentCoins = snapshot['coins'] ?? 0;

        transaction.update(userRef, {
          'coins': currentCoins + amount,
        });

        await _firestore.collection('coin_transactions').add({
          'playerId': playerId,
          'amount': amount,
          'reason': reason,
          'timestamp': Timestamp.now(),
          'balanceBefore': currentCoins,
          'balanceAfter': currentCoins + amount,
        });
      });
    } catch (e) {
      throw 'Failed to add coins: $e';
    }
  }

  Future<int> getPlayerCoins(String playerId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(playerId).get();
      return doc['coins'] ?? 0;
    } catch (e) {
      throw 'Failed to fetch coins: $e';
    }
  }
}