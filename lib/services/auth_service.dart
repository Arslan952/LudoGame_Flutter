import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signUpWithEmail(String email, String password, String username) async {
    try {
      print("Check Function work");
      UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      print(user!.displayName);
      print(user.email);

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'username': username,
          'coins': 100,
          'level': 1,
          'totalWins': 0,
          'totalLosses': 0,
          'totalMatches': 0,
          'winRate': 0.0,
          'avatarUrl': null,
          'createdAt': Timestamp.now(),
          'lastLogin': Timestamp.now(),
          'status': 'online',
          'lastDailyRewardDate': '',
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print("Creating user");
      print(e);
      throw _handleAuthException(e);
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'lastLogin': Timestamp.now(),
          'status': 'online',
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> signOut() async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'status': 'offline',
        });
      }
      await _firebaseAuth.signOut();
    } catch (e) {
      throw 'Sign out failed: $e';
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak';
      case 'email-already-in-use':
        return 'Email already exists';
      case 'user-not-found':
        return 'User not found';
      case 'wrong-password':
        return 'Wrong password';
      case 'invalid-email':
        return 'Invalid email format';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }

  User? getCurrentUser() => _firebaseAuth.currentUser;
}