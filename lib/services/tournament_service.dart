import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/tournament_model.dart';

class TournamentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> createTournament(
    String name,
    int maxPlayers,
    int entryFee,
    List<int> prizePool,
  ) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw 'User not authenticated';

      DocumentReference tournamentRef = await _firestore
          .collection('tournaments')
          .add({
            'name': name,
            'maxPlayers': maxPlayers,
            'entryFee': entryFee,
            'prizePool': prizePool,
            'status': 'open',
            'registeredPlayers': [user.uid],
            'bracket': {},
            'createdAt': Timestamp.now(),
            'startDate': Timestamp.now(),
            'endDate': null,
            'creatorId': user.uid,
          });

      return tournamentRef.id;
    } catch (e) {
      throw 'Failed to create tournament: $e';
    }
  }

  Future<TournamentModel> getTournament(String tournamentId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .get();
      if (doc.exists) {
        return TournamentModel.fromFirestore(doc);
      }
      throw 'Tournament not found';
    } catch (e) {
      throw 'Failed to fetch tournament: $e';
    }
  }

  Future<List<TournamentModel>> getTournaments() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('tournaments')
          .where('status', isEqualTo: 'open')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TournamentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to fetch tournaments: $e';
    }
  }

  Future<void> joinTournament(String tournamentId) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw 'User not authenticated';

      await _firestore.collection('tournaments').doc(tournamentId).update({
        'registeredPlayers': FieldValue.arrayUnion([user.uid]),
      });
    } catch (e) {
      throw 'Failed to join tournament: $e';
    }
  }

  Stream<TournamentModel> streamTournament(String tournamentId) {
    return _firestore
        .collection('tournaments')
        .doc(tournamentId)
        .snapshots()
        .map((doc) => TournamentModel.fromFirestore(doc));
  }
}
