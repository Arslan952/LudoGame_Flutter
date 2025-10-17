import 'package:flutter/material.dart';
import 'package:ludo_game/screens/game/widget/dice_widget.dart';
import 'package:ludo_game/screens/game/widget/ludo_board.dart';
import 'package:provider/provider.dart';

import '../../models/game_model.dart';
import '../../provider/gameProvider.dart';


class GameBoardScreen extends StatefulWidget {
  final String gameId;
  final String currentUserId;

  const GameBoardScreen({
    Key? key,
    required this.gameId,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<GameBoardScreen> createState() => _GameBoardScreenState();
}

class _GameBoardScreenState extends State<GameBoardScreen> {
  int? selectedTokenIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().streamGame(widget.gameId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text('Ludo Game'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showGameInfo(context),
          ),
        ],
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          if (gameProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (gameProvider.currentGame == null) {
            return const Center(
              child: Text('Game not found'),
            );
          }

          final game = gameProvider.currentGame!;
          final isMyTurn = game.currentPlayerId == widget.currentUserId;
          final currentPlayerIndex = game.playerIds.indexOf(widget.currentUserId);
          final playerColor = _getPlayerColor(currentPlayerIndex);

          return Column(
            children: [
              // Top player info
              _buildPlayerInfoBar(game, 1),

              // Game board
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: GestureDetector(
                            onTapUp: (details) {
                              if (isMyTurn && game.diceRolled) {
                                _handleBoardTap(context, details, game);
                              }
                            },
                            child: CustomPaint(
                              painter: LudoBoardPainter(
                                gameState: game,
                                selectedTokenIndex: selectedTokenIndex,
                                currentPlayerId: widget.currentUserId,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom player info
              _buildPlayerInfoBar(game, 3),

              // Dice and controls
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Current turn indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isMyTurn
                            ? Colors.green.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isMyTurn ? Colors.green : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isMyTurn ? Icons.touch_app : Icons.watch_later,
                            color: isMyTurn ? Colors.green : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isMyTurn
                                ? 'Your Turn!'
                                : '${game.playerNames[game.currentTurnIndex]}\'s Turn',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isMyTurn ? Colors.green : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dice and action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Left player info
                        _buildSidePlayerInfo(game, 0),

                        // Dice in center
                        Column(
                          children: [
                            DiceWidget(
                              value: game.currentTurnDiceValue > 0
                                  ? game.currentTurnDiceValue
                                  : 1,
                              isRolling: gameProvider.isRolling,
                              isEnabled: isMyTurn && !game.diceRolled,
                              diceColor: playerColor,
                              onRoll: isMyTurn && !game.diceRolled
                                  ? () => _rollDice(context, gameProvider)
                                  : null,
                            ),
                            const SizedBox(height: 8),
                            if (game.diceRolled && isMyTurn)
                              Text(
                                'Select a token to move',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),

                        // Right player info
                        _buildSidePlayerInfo(game, 2),
                      ],
                    ),

                    // Valid moves indicator
                    if (game.diceRolled && isMyTurn && gameProvider.validMoves.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Valid moves: ${gameProvider.validMoves.map((i) => 'Token ${i + 1}').join(', ')}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                    // No moves available
                    if (game.diceRolled && isMyTurn && gameProvider.validMoves.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: ElevatedButton(
                          onPressed: () => _skipTurn(context, gameProvider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text('No valid moves - Skip Turn'),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlayerInfoBar(GameModel game, int playerIndex) {
    if (playerIndex >= game.playerIds.length) {
      return const SizedBox(height: 60);
    }

    final isCurrentPlayer = game.currentTurnIndex == playerIndex;
    final playerColor = _getPlayerColor(playerIndex);
    final playerName = game.playerNames[playerIndex];
    final tokensInHome = game.tokenPositions[game.playerIds[playerIndex]]
        ?.where((pos) => pos == -1)
        .length ??
        0;
    final tokensFinished = game.tokenPositions[game.playerIds[playerIndex]]
        ?.where((pos) => pos >= 58)
        .length ??
        0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentPlayer ? playerColor.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentPlayer ? playerColor : Colors.grey.shade300,
          width: isCurrentPlayer ? 3 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: playerColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                playerName[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  playerName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isCurrentPlayer ? playerColor : Colors.black87,
                  ),
                ),
                Text(
                  'Home: $tokensInHome | Finished: $tokensFinished',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (isCurrentPlayer)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: playerColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Playing',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSidePlayerInfo(GameModel game, int playerIndex) {
    if (playerIndex >= game.playerIds.length) {
      return const SizedBox(width: 60);
    }

    final playerColor = _getPlayerColor(playerIndex);
    final playerName = game.playerNames[playerIndex];
    final isCurrentPlayer = game.currentTurnIndex == playerIndex;

    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: playerColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrentPlayer ? Colors.white : Colors.transparent,
              width: 3,
            ),
            boxShadow: isCurrentPlayer
                ? [
              BoxShadow(
                color: playerColor.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ]
                : [],
          ),
          child: Center(
            child: Text(
              playerName[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          playerName.length > 8
              ? '${playerName.substring(0, 8)}...'
              : playerName,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isCurrentPlayer ? FontWeight.bold : FontWeight.normal,
            color: isCurrentPlayer ? playerColor : Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Color _getPlayerColor(int playerIndex) {
    const colors = [
      Colors.red,
      Colors.green,
      Color(0xFFFFD700), // Yellow/Gold
      Colors.blue,
    ];
    return colors[playerIndex % colors.length];
  }

  Future<void> _rollDice(BuildContext context, GameProvider gameProvider) async {
    await gameProvider.rollDice(widget.gameId, widget.currentUserId);
  }

  Future<void> _skipTurn(BuildContext context, GameProvider gameProvider) async {
    await gameProvider.nextTurn(widget.gameId);
    setState(() {
      selectedTokenIndex = null;
    });
  }

  void _handleBoardTap(
      BuildContext context,
      TapUpDetails details,
      GameModel game,
      ) {
    final gameProvider = context.read<GameProvider>();

    if (!gameProvider.validMoves.isNotEmpty) return;

    // Calculate which token was tapped (simplified - you'd need proper hit detection)
    // For now, cycle through valid moves on each tap
    if (selectedTokenIndex == null) {
      setState(() {
        selectedTokenIndex = gameProvider.validMoves.first;
      });
    } else {
      _moveSelectedToken(context, gameProvider);
    }
  }

  Future<void> _moveSelectedToken(
      BuildContext context,
      GameProvider gameProvider,
      ) async {
    if (selectedTokenIndex == null) return;

    final success = await gameProvider.moveToken(
      widget.gameId,
      selectedTokenIndex!,
      widget.currentUserId,
    );

    if (success) {
      await Future.delayed(const Duration(milliseconds: 300));
      await gameProvider.nextTurn(widget.gameId);
      setState(() {
        selectedTokenIndex = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid move'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _showGameInfo(BuildContext context) {
    final game = context.read<GameProvider>().currentGame;
    if (game == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Game ID: ${game.gameId}'),
            const SizedBox(height: 8),
            Text('Entry Fee: \$${game.entryFee}'),
            Text('Prize Pool: \$${game.totalPrize}'),
            const SizedBox(height: 8),
            Text('Status: ${game.gameStatus}'),
            const SizedBox(height: 16),
            const Text(
              'Players:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...game.playerNames.map((name) => Text('• $name')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}