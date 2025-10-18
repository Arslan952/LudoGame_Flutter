import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../provider/authProvider.dart';
import '../../provider/coinProvider.dart';
import '../../services/route/route.dart';

class MatchmakingWaitingScreen extends StatefulWidget {
  final int numPlayers;
  final int entryFee;

  const MatchmakingWaitingScreen({
    super.key,
    required this.numPlayers,
    required this.entryFee,
  });

  @override
  State<MatchmakingWaitingScreen> createState() =>
      _MatchmakingWaitingScreenState();
}

class _MatchmakingWaitingScreenState extends State<MatchmakingWaitingScreen>
    with TickerProviderStateMixin {
  List<PlayerInfo> waitingPlayers = [];
  bool gameStarted = false;
  late AnimationController _animationController;
  String? gameId;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _deductCoinsAndAddToQueue();
    _watchMatchmaking();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _deductCoinsAndAddToQueue() async {
    final authProvider = context.read<AuthProvider>();
    final coinProvider = context.read<CoinProvider>();

    if (authProvider.currentUser != null && authProvider.userModel != null) {
      try {
        // Deduct entry fee
        await coinProvider.deductCoins(
          authProvider.currentUser!.uid,
          widget.entryFee,
          'Game entry fee',
        );

        // Add to matchmaking queue
        await FirebaseFirestore.instance.collection('matchmaking_queue').add({
          'playerId': authProvider.currentUser!.uid,
          'playerName': authProvider.userModel!.username,
          'avatarUrl': authProvider.userModel!.avatarUrl,
          'numPlayers': widget.numPlayers,
          'entryFee': widget.entryFee,
          'joinedAt': Timestamp.now(),
          'status': 'waiting',
          'matched': false,
        });
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  void _watchMatchmaking() {
    FirebaseFirestore.instance
        .collection('matchmaking_queue')
        .where('numPlayers', isEqualTo: widget.numPlayers)
        .where('status', isEqualTo: 'waiting')
        .snapshots()
        .listen((snapshot) {
          List<PlayerInfo> players = [];
          for (var doc in snapshot.docs) {
            players.add(
              PlayerInfo(
                playerId: doc['playerId'],
                playerName: doc['playerName'],
                avatarUrl: doc['avatarUrl'],
                joinedAt: (doc['joinedAt'] as Timestamp).toDate(),
              ),
            );
          }

          setState(() {
            waitingPlayers = players;
          });

          // Check if game should start
          if (waitingPlayers.length >= widget.numPlayers && !gameStarted) {
            _createGame();
          }
        });
  }

  Future<void> _createGame() async {
    try {
      setState(() => gameStarted = true);

      List<String> playerIds = waitingPlayers.map((p) => p.playerId).toList();
      List<String> playerNames = waitingPlayers
          .map((p) => p.playerName)
          .toList();

      // Create game document
      DocumentReference gameRef = await FirebaseFirestore.instance
          .collection('games')
          .add({
            'playerIds': playerIds.take(widget.numPlayers).toList(),
            'playerNames': playerNames.take(widget.numPlayers).toList(),
            'playerColors': List.generate(widget.numPlayers, (i) => i),
            'currentTurnPlayerId': playerIds.first,
            'currentTurnIndex': 0,
            'currentTurnDiceValue': 0,
            'tokenPositions': {
              for (String id in playerIds.take(widget.numPlayers))
                id: [-1, -1, -1, -1],
            },
            'gameStatus': 'playing',
            'winnerId': null,
            'playerRanking': [],
            'entryFee': widget.entryFee,
            'totalPrize': widget.entryFee * widget.numPlayers,
            'createdAt': Timestamp.now(),
            'updatedAt': Timestamp.now(),
            'moveHistory': [],
          });

      gameId = gameRef.id;

      // Update queue status
      for (var player in waitingPlayers.take(widget.numPlayers)) {
        QuerySnapshot queueDocs = await FirebaseFirestore.instance
            .collection('matchmaking_queue')
            .where('playerId', isEqualTo: player.playerId)
            .get();

        for (var doc in queueDocs.docs) {
          await doc.reference.update({
            'matched': true,
            'gameId': gameId,
            'status': 'matched',
          });
        }
      }

      if (mounted) {
        await Future.delayed(const Duration(seconds: 2));
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.gameBoard,
          arguments: {
            'gameId': gameId,
            'numPlayers': widget.numPlayers,
            'entryFee': widget.entryFee,
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating game: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade400, Colors.purple.shade400],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Text(
                  'Finding ${widget.numPlayers} Players',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_animationController.value * 0.2),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        child: Center(
                          child: Text(
                            '${waitingPlayers.length}/${widget.numPlayers}',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 60),
                Expanded(
                  child: ListView.builder(
                    itemCount: waitingPlayers.length,
                    itemBuilder: (context, index) {
                      final player = waitingPlayers[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.blue,
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      player.playerName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Joined ${_getTimeAgo(player.joinedAt)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                if (waitingPlayers.length < widget.numPlayers)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                      ),
                      onPressed: _cancelMatchmaking,
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                if (waitingPlayers.length == widget.numPlayers && gameStarted)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(color: Colors.white),
                        const SizedBox(height: 12),
                        const Text(
                          'Starting Game...',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${difference.inHours}h ago';
    }
  }

  Future<void> _cancelMatchmaking() async {
    try {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser != null) {
        QuerySnapshot queueDocs = await FirebaseFirestore.instance
            .collection('matchmaking_queue')
            .where('playerId', isEqualTo: authProvider.currentUser!.uid)
            .get();

        for (var doc in queueDocs.docs) {
          await doc.reference.delete();
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }
}

class PlayerInfo {
  final String playerId;
  final String playerName;
  final String? avatarUrl;
  final DateTime joinedAt;

  PlayerInfo({
    required this.playerId,
    required this.playerName,
    this.avatarUrl,
    required this.joinedAt,
  });
}
