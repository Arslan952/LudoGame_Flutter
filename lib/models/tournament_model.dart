import 'package:cloud_firestore/cloud_firestore.dart';

class TournamentModel {
  final String tournamentId;
  final String name;
  final int maxPlayers;
  final int entryFee;
  final List<int> prizePool; // [1st, 2nd, 3rd, etc.]
  final String status; // 'open', 'in-progress', 'completed'
  final List<String> registeredPlayers;
  final Map<String, dynamic> bracket;
  final DateTime createdAt;
  final DateTime startDate;
  final DateTime? endDate;
  final String creatorId;

  TournamentModel({
    required this.tournamentId,
    required this.name,
    required this.maxPlayers,
    required this.entryFee,
    required this.prizePool,
    required this.status,
    required this.registeredPlayers,
    required this.bracket,
    required this.createdAt,
    required this.startDate,
    this.endDate,
    required this.creatorId,
  });

  factory TournamentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TournamentModel(
      tournamentId: doc.id,
      name: data['name'] ?? '',
      maxPlayers: data['maxPlayers'] ?? 0,
      entryFee: data['entryFee'] ?? 0,
      prizePool: List<int>.from(data['prizePool'] ?? []),
      status: data['status'] ?? 'open',
      registeredPlayers: List<String>.from(data['registeredPlayers'] ?? []),
      bracket: data['bracket'] ?? {},
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : null,
      creatorId: data['creatorId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'maxPlayers': maxPlayers,
    'entryFee': entryFee,
    'prizePool': prizePool,
    'status': status,
    'registeredPlayers': registeredPlayers,
    'bracket': bracket,
    'createdAt': Timestamp.fromDate(createdAt),
    'startDate': Timestamp.fromDate(startDate),
    'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
    'creatorId': creatorId,
  };
}
