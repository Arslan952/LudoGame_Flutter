import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String username;
  final String? avatarUrl;
  final int coins;
  final int level;
  final int totalWins;
  final int totalLosses;
  final int totalMatches;
  final double winRate;
  final DateTime createdAt;
  final DateTime lastLogin;
  final String status; // 'online', 'offline', 'in-game'

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    this.avatarUrl,
    required this.coins,
    required this.level,
    required this.totalWins,
    required this.totalLosses,
    required this.totalMatches,
    required this.winRate,
    required this.createdAt,
    required this.lastLogin,
    required this.status,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      username: data['username'] ?? 'Unknown',
      avatarUrl: data['avatarUrl'],
      coins: data['coins'] ?? 0,
      level: data['level'] ?? 1,
      totalWins: data['totalWins'] ?? 0,
      totalLosses: data['totalLosses'] ?? 0,
      totalMatches: data['totalMatches'] ?? 0,
      winRate: (data['winRate'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLogin: (data['lastLogin'] as Timestamp).toDate(),
      status: data['status'] ?? 'offline',
    );
  }

  Map<String, dynamic> toMap() => {
    'email': email,
    'username': username,
    'avatarUrl': avatarUrl,
    'coins': coins,
    'level': level,
    'totalWins': totalWins,
    'totalLosses': totalLosses,
    'totalMatches': totalMatches,
    'winRate': winRate,
    'createdAt': Timestamp.fromDate(createdAt),
    'lastLogin': Timestamp.fromDate(lastLogin),
    'status': status,
  };
}
