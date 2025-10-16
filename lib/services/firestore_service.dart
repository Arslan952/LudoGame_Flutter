import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      throw 'User not found';
    } catch (e) {
      throw 'Failed to fetch user: $e';
    }
  }

  Stream<UserModel> streamUser(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => UserModel.fromFirestore(doc));
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw 'Failed to update user: $e';
    }
  }

  Future<void> updateUserStatus(String uid, String status) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'status': status,
      });
    } catch (e) {
      throw 'Failed to update status: $e';
    }
  }

  Future<List<UserModel>> getLeaderboard({int limit = 50}) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .orderBy('coins', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to fetch leaderboard: $e';
    }
  }

  Stream<List<UserModel>> streamLeaderboard({int limit = 50}) {
    return _firestore
        .collection('users')
        .orderBy('coins', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .toList());
  }
}