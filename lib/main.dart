import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const LudoApp());
}

class LudoApp extends StatelessWidget {
  const LudoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ludo Game',
      theme: ThemeData(primarySwatch: Colors.deepPurple, useMaterial3: true),
      home: const PlayerSelectionScreen(),
    );
  }
}

// ==================== MODELS ====================

class Token {
  final String color;
  final int homeIndex;
  int positionIndex; // -1 = home, 0-56 = path, 57 = finished
  bool isFinished;

  Token({
    required this.color,
    required this.homeIndex,
    this.positionIndex = -1,
    this.isFinished = false,
  });

  bool get isAtHome => positionIndex == -1;

  bool get isOnPath => positionIndex >= 0 && !isFinished;
}

class Player {
  final String color;
  final List<Token> tokens;

  Player({required this.color, required this.tokens});

  int get finishedTokens => tokens.where((t) => t.isFinished).length;

  bool get hasWon => finishedTokens == 4;
}

// ==================== PATH GENERATOR ====================

class PathGenerator {
  static Map<String, List<Offset>> generatePaths(double cellSize) {
    return {
      'red': _generateColorPath(cellSize, 'red'),
      'green': _generateColorPath(cellSize, 'green'),
      'yellow': _generateColorPath(cellSize, 'yellow'),
      'blue': _generateColorPath(cellSize, 'blue'),
    };
  }

  static List<Offset> _generateColorPath(double cellSize, String color) {
    List<Offset> path = [];

    // Generate main circular path (common for all colors)
    path.addAll(_generateCircularPath(cellSize));

    // Add colored home stretch path
    path.addAll(_generateHomeStretchPath(cellSize, color));

    return path;
  }

  static List<Offset> _generateCircularPath(double cellSize) {
    List<Offset> path = [];

    // Right movement on row 7 (red starting area)
    for (int col = 3; col <= 9; col++) {
      path.add(
        Offset(
          (col - 1) * cellSize + cellSize / 2,
          (7 - 1) * cellSize + cellSize / 2,
        ),
      );
    }

    // Down movement on column 9 (green starting area)
    for (int row = 8; row <= 14; row++) {
      path.add(
        Offset(
          (9 - 1) * cellSize + cellSize / 2,
          (row - 1) * cellSize + cellSize / 2,
        ),
      );
    }

    // Left movement on row 14 (yellow starting area)
    for (int col = 8; col >= 1; col--) {
      path.add(
        Offset(
          (col - 1) * cellSize + cellSize / 2,
          (14 - 1) * cellSize + cellSize / 2,
        ),
      );
    }

    // Up movement on column 1 (blue starting area)
    for (int row = 13; row >= 1; row--) {
      path.add(
        Offset(
          (1 - 1) * cellSize + cellSize / 2,
          (row - 1) * cellSize + cellSize / 2,
        ),
      );
    }

    // Right movement on row 1 (back to red area)
    for (int col = 2; col <= 8; col++) {
      path.add(
        Offset(
          (col - 1) * cellSize + cellSize / 2,
          (1 - 1) * cellSize + cellSize / 2,
        ),
      );
    }

    return path;
  }

  static List<Offset> _generateHomeStretchPath(double cellSize, String color) {
    List<Offset> homePath = [];

    switch (color) {
      case 'red':
        // Red home stretch - down on column 8
        for (int row = 2; row <= 7; row++) {
          homePath.add(
            Offset(
              (8 - 1) * cellSize + cellSize / 2,
              (row - 1) * cellSize + cellSize / 2,
            ),
          );
        }
        break;
      case 'green':
        // Green home stretch - left on row 8
        for (int col = 8; col >= 7; col--) {
          homePath.add(
            Offset(
              (col - 1) * cellSize + cellSize / 2,
              (8 - 1) * cellSize + cellSize / 2,
            ),
          );
        }
        break;
      case 'yellow':
        // Yellow home stretch - up on column 8
        for (int row = 14; row >= 9; row--) {
          homePath.add(
            Offset(
              (8 - 1) * cellSize + cellSize / 2,
              (row - 1) * cellSize + cellSize / 2,
            ),
          );
        }
        break;
      case 'blue':
        // Blue home stretch - right on row 8
        for (int col = 2; col <= 7; col++) {
          homePath.add(
            Offset(
              (col - 1) * cellSize + cellSize / 2,
              (8 - 1) * cellSize + cellSize / 2,
            ),
          );
        }
        break;
    }

    return homePath;
  }
}

// ==================== PATH VALIDATOR ====================

class PathValidator {
  // Check if token movement follows proper legal path
  static bool isValidMove(
    Token token,
    int diceValue,
    List<String> activePlayers,
  ) {
    if (token.isFinished) return false;

    if (token.isAtHome) {
      // Token can only leave home with a 6
      return diceValue == 6;
    } else {
      // Token on path - check bounds
      final newPosition = token.positionIndex + diceValue;
      return newPosition <= 56; // Maximum path index
    }
  }

  // Check if move would capture opponent's token
  static bool wouldCapture(
    Token movingToken,
    int newPosition,
    Map<String, Player> players,
    Map<String, List<Offset>> paths,
  ) {
    if (newPosition > 56) return false;

    final movingTokenPos = paths[movingToken.color]![newPosition];

    for (var color in players.keys) {
      if (color == movingToken.color) continue;

      for (var opponentToken in players[color]!.tokens) {
        if (opponentToken.isOnPath &&
            !_isSafeSquare(opponentToken.positionIndex, color)) {
          final opponentPos = paths[color]![opponentToken.positionIndex];
          if ((opponentPos - movingTokenPos).distance < 1) {
            return true;
          }
        }
      }
    }
    return false;
  }

  // Check if position is a safe square (cannot be captured)
  static bool _isSafeSquare(int position, String color) {
    // These are the safe squares where tokens cannot be captured
    final safePositions = {
      'red': [0, 8, 13, 21, 26, 34, 39, 47],
      'green': [4, 8, 17, 21, 30, 34, 43, 47],
      'yellow': [4, 8, 17, 21, 30, 34, 43, 47],
      'blue': [4, 8, 17, 21, 30, 34, 43, 47],
    };
    return safePositions[color]?.contains(position) ?? false;
  }
}

// ==================== SCREENS ====================

class PlayerSelectionScreen extends StatefulWidget {
  const PlayerSelectionScreen({Key? key}) : super(key: key);

  @override
  State<PlayerSelectionScreen> createState() => _PlayerSelectionScreenState();
}

class _PlayerSelectionScreenState extends State<PlayerSelectionScreen> {
  int selectedPlayers = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎲 Ludo Game'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select Number of Players',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            // Player selection buttons
            for (int i = 2; i <= 4; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: ElevatedButton(
                  onPressed: () => setState(() => selectedPlayers = i),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedPlayers == i
                        ? Colors.deepPurple
                        : Colors.grey[300],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 20,
                    ),
                  ),
                  child: Text(
                    '$i Players',
                    style: TextStyle(
                      fontSize: 18,
                      color: selectedPlayers == i ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 50),
            // Start game button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LudoGameScreen(numPlayers: selectedPlayers),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow, size: 28),
              label: const Text('Start Game'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LudoGameScreen extends StatefulWidget {
  final int numPlayers;

  const LudoGameScreen({required this.numPlayers, Key? key}) : super(key: key);

  @override
  State<LudoGameScreen> createState() => _LudoGameScreenState();
}

class _LudoGameScreenState extends State<LudoGameScreen>
    with TickerProviderStateMixin {
  late List<String> activePlayers;
  late Map<String, Player> players;
  late Map<String, List<Offset>> paths;
  late AnimationController diceController;
  late AnimationController moveController;

  int currentPlayerIndex = 0;
  int diceValue = 0;
  bool isDiceRolled = false;
  bool canSelectToken = false;
  String gameMessage = '';
  int consecutiveSixes = 0;
  List<int> finishOrder = [];

  @override
  void initState() {
    super.initState();
    // Initialize animation controllers for dice rolling and token movement
    diceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    moveController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _initGame();
  }

  void _initGame() {
    // Initialize players based on selection
    activePlayers = [
      'red',
      'green',
      'yellow',
      'blue',
    ].take(widget.numPlayers).toList();

    players = {};
    for (var color in activePlayers) {
      players[color] = Player(
        color: color,
        tokens: [for (int i = 0; i < 4; i++) Token(color: color, homeIndex: i)],
      );
    }
  }

  void _rollDice() {
    if (isDiceRolled) return;

    // Animate dice roll
    diceController.forward().then((_) {
      setState(() {
        diceValue = Random().nextInt(6) + 1;
        isDiceRolled = true;
        canSelectToken = true;

        if (diceValue == 6) {
          consecutiveSixes++;
          if (consecutiveSixes >= 3) {
            gameMessage = '❌ Three 6s in a row! Turn skipped!';
            _autoSkipTurn();
            return;
          }
          gameMessage = '🎉 Rolled 6! Get another turn!';
        } else {
          consecutiveSixes = 0;
          gameMessage = 'Rolled $diceValue';
        }

        // Check if player has any legal moves
        if (!_hasLegalMove()) {
          gameMessage += '\n⏭️ No legal moves available';
          canSelectToken = false;
          _autoSkipTurn();
        }
      });
      diceController.reset();
    });
  }

  bool _hasLegalMove() {
    final currentColor = activePlayers[currentPlayerIndex];
    final playerTokens = players[currentColor]!.tokens;

    for (var token in playerTokens) {
      if (PathValidator.isValidMove(token, diceValue, activePlayers)) {
        return true;
      }
    }
    return false;
  }

  void _moveToken(int tokenIndex) {
    if (!canSelectToken || !isDiceRolled) return;

    final currentColor = activePlayers[currentPlayerIndex];
    final token = players[currentColor]!.tokens[tokenIndex];

    // Validate the move using PathValidator
    if (!PathValidator.isValidMove(token, diceValue, activePlayers)) {
      setState(() => gameMessage = '❌ Invalid move!');
      return;
    }

    int newPosition;
    if (token.isAtHome && diceValue == 6) {
      newPosition = 0; // Start from beginning of path
    } else {
      newPosition = token.positionIndex + diceValue;
    }

    _executeMove(token, newPosition);
  }

  void _executeMove(Token token, int newPosition) {
    setState(() {
      token.positionIndex = newPosition;
      if (newPosition == 56) {
        token.isFinished = true;
        gameMessage = '✅ Token reached home!';
      }
      isDiceRolled = false;
      canSelectToken = false;
    });

    _checkCaptureAndWin(token);

    Future.delayed(const Duration(milliseconds: 500), () {
      _checkWin();
      if (diceValue != 6 || token.isFinished) {
        _nextPlayer();
      } else {
        setState(() => gameMessage = '🎉 You have another turn!');
      }
    });
  }

  void _checkCaptureAndWin(Token movedToken) {
    if (movedToken.isFinished) return;

    final movedPos = paths[movedToken.color]![movedToken.positionIndex];

    for (var color in activePlayers) {
      if (color == movedToken.color) continue;

      for (var token in players[color]!.tokens) {
        if (token.isOnPath) {
          final tokenPos = paths[color]![token.positionIndex];
          if ((tokenPos - movedPos).distance < 1) {
            setState(() {
              token.positionIndex = -1; // Send back to home
              gameMessage = '💥 Captured ${color.toUpperCase()} token!';
            });
          }
        }
      }
    }
  }

  void _checkWin() {
    final currentColor = activePlayers[currentPlayerIndex];
    if (players[currentColor]!.hasWon) {
      if (!finishOrder.contains(currentPlayerIndex)) {
        finishOrder.add(currentPlayerIndex);
      }

      if (finishOrder.length == activePlayers.length) {
        _showGameOverDialog();
      } else {
        _nextPlayer();
      }
    }
  }

  void _autoSkipTurn() {
    Future.delayed(const Duration(seconds: 2), _nextPlayer);
  }

  void _nextPlayer() {
    setState(() {
      do {
        currentPlayerIndex = (currentPlayerIndex + 1) % activePlayers.length;
      } while (finishOrder.contains(currentPlayerIndex));

      diceValue = 0;
      isDiceRolled = false;
      canSelectToken = false;
      gameMessage = '';
      consecutiveSixes = 0;
    });
  }

  void _showGameOverDialog() {
    final winners = finishOrder.map((i) => activePlayers[i]).toList();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('🏆 Game Over!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Final Ranking:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            for (int i = 0; i < winners.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text('${i + 1}. ${winners[i].toUpperCase()}'),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const PlayerSelectionScreen(),
                ),
              );
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  double _getBoardSize() {
    final screenWidth = MediaQuery.of(context).size.width;
    return min(screenWidth - 32, 450);
  }

  @override
  void dispose() {
    diceController.dispose();
    moveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final boardSize = _getBoardSize();
    paths = PathGenerator.generatePaths(boardSize / 15);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${activePlayers[currentPlayerIndex].toUpperCase()}\'s Turn',
        ),
        centerTitle: true,
        backgroundColor: _colorForPlayer(activePlayers[currentPlayerIndex]),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Dice widget with roll animation
            GestureDetector(
              onTap: _rollDice,
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 1.0,
                  end: 1.15,
                ).animate(diceController),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      isDiceRolled ? '$diceValue' : '🎲',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              gameMessage,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            // Game board
            Center(
              child: Stack(
                children: [
                  EnhancedLudoBoardWidget(boardSize: boardSize),
                  ..._buildTokenWidgets(boardSize),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Token selection buttons
            if (canSelectToken && _hasLegalMove())
              Wrap(
                spacing: 8,
                children: [
                  for (
                    int i = 0;
                    i <
                        players[activePlayers[currentPlayerIndex]]!
                            .tokens
                            .length;
                    i++
                  )
                    ElevatedButton(
                      onPressed: () => _moveToken(i),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _colorForPlayer(
                          activePlayers[currentPlayerIndex],
                        ),
                      ),
                      child: Text('T${i + 1}'),
                    ),
                ],
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTokenWidgets(double boardSize) {
    List<Widget> widgets = [];
    final cellSize = boardSize / 15;

    final homePositions = {
      'red': [(2, 2), (2, 5), (5, 2), (5, 5)],
      'green': [(2, 11), (2, 14), (5, 11), (5, 14)],
      'yellow': [(11, 11), (11, 14), (14, 11), (14, 14)],
      'blue': [(11, 2), (11, 5), (14, 2), (14, 5)],
    };

    for (var color in activePlayers) {
      for (int i = 0; i < 4; i++) {
        final token = players[color]!.tokens[i];
        late Offset offset;

        if (token.isAtHome) {
          // Position token in home area
          final (row, col) = homePositions[color]![i] as (int, int);
          offset = Offset(
            (col - 1) * cellSize + cellSize / 2,
            (row - 1) * cellSize + cellSize / 2,
          );
        } else if (token.isFinished) {
          // Position finished token in center
          offset = Offset(
            (8 - 1) * cellSize + cellSize / 2,
            (8 - 1) * cellSize + cellSize / 2,
          );
        } else {
          // Position token on path
          offset = paths[color]![token.positionIndex];
        }

        widgets.add(
          Positioned(
            left: offset.dx - 12,
            top: offset.dy - 12,
            child: TweenAnimationBuilder<Offset>(
              tween: Tween(begin: offset, end: offset),
              duration: const Duration(milliseconds: 300),
              builder: (_, value, __) => Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _colorForPlayer(color),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }

  Color _colorForPlayer(String color) {
    switch (color) {
      case 'red':
        return Colors.red[700]!;
      case 'green':
        return Colors.green[700]!;
      case 'yellow':
        return Colors.amber[700]!;
      case 'blue':
        return Colors.blue[700]!;
      default:
        return Colors.grey;
    }
  }
}

// ==================== ENHANCED BOARD WIDGETS ====================

class EnhancedLudoBoardWidget extends StatelessWidget {
  final double boardSize;

  const EnhancedLudoBoardWidget({required this.boardSize, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CustomPaint(
          painter: EnhancedLudoBoardPainter(),
          size: Size(boardSize, boardSize),
        ),
      ),
    );
  }
}

class EnhancedLudoBoardPainter extends CustomPainter {
  static const int gridSize = 15;
  static const Color redColor = Color(0xFFD32F2F);
  static const Color greenColor = Color(0xFF388E3C);
  static const Color yellowColor = Color(0xFFFBC02D);
  static const Color blueColor = Color(0xFF1976D2);
  static const Color starColor = Color(0xFFFFB300);
  static const Color trackWhite = Color(0xFFFFFFFF);
  static const Color centerColor = Color(0xFFE1BEE7);

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / gridSize;

    // Draw board components in order
    _drawBaseBoard(canvas, cellSize);
    _drawColoredHomes(canvas, cellSize);
    _drawCenterArea(canvas, cellSize);
    _drawTracks(canvas, cellSize);
    _drawGridLines(canvas, cellSize);
    _drawSafeSquares(canvas, cellSize);
    _drawCenterTriangles(canvas, cellSize);
    _drawHomeStretches(canvas, cellSize);
    _drawBorder(canvas, size);
  }

  void _drawBaseBoard(Canvas canvas, double cellSize) {
    // Draw base white background
    final basePaint = Paint()..color = const Color(0xFFF8F8F8);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, gridSize * cellSize, gridSize * cellSize),
      basePaint,
    );
  }

  void _drawColoredHomes(Canvas canvas, double cellSize) {
    // Draw red home (top-left)
    _drawHome(canvas, 1, 1, 6, 6, redColor, cellSize);
    // Draw green home (top-right)
    _drawHome(canvas, 1, 10, 6, 6, greenColor, cellSize);
    // Draw yellow home (bottom-right)
    _drawHome(canvas, 10, 10, 6, 6, yellowColor, cellSize);
    // Draw blue home (bottom-left)
    _drawHome(canvas, 10, 1, 6, 6, blueColor, cellSize);
  }

  void _drawHome(
    Canvas canvas,
    int startRow,
    int startCol,
    int width,
    int height,
    Color color,
    double cellSize,
  ) {
    final homePaint = Paint()..color = color;
    final homeRect = Rect.fromLTWH(
      (startCol - 1) * cellSize,
      (startRow - 1) * cellSize,
      width * cellSize,
      height * cellSize,
    );
    canvas.drawRect(homeRect, homePaint);

    // Draw home border
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(homeRect, borderPaint);
  }

  void _drawCenterArea(Canvas canvas, double cellSize) {
    // Draw center diamond area
    final centerRect = Rect.fromLTWH(
      6 * cellSize,
      6 * cellSize,
      3 * cellSize,
      3 * cellSize,
    );
    canvas.drawRect(centerRect, Paint()..color = centerColor);

    // Draw center border
    canvas.drawRect(
      centerRect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawTracks(Canvas canvas, double cellSize) {
    final trackPaint = Paint()..color = trackWhite;

    // Horizontal tracks
    for (int col = 1; col <= 15; col++) {
      if (col >= 2 && col <= 6) continue; // Skip home areas
      if (col >= 10 && col <= 14) continue;

      // Row 7 track
      canvas.drawRect(
        Rect.fromLTWH((col - 1) * cellSize, 6 * cellSize, cellSize, cellSize),
        trackPaint,
      );
      // Row 9 track
      canvas.drawRect(
        Rect.fromLTWH((col - 1) * cellSize, 8 * cellSize, cellSize, cellSize),
        trackPaint,
      );
    }

    // Vertical tracks
    for (int row = 1; row <= 15; row++) {
      if (row >= 2 && row <= 6) continue; // Skip home areas
      if (row >= 10 && row <= 14) continue;

      // Column 7 track
      canvas.drawRect(
        Rect.fromLTWH(6 * cellSize, (row - 1) * cellSize, cellSize, cellSize),
        trackPaint,
      );
      // Column 9 track
      canvas.drawRect(
        Rect.fromLTWH(8 * cellSize, (row - 1) * cellSize, cellSize, cellSize),
        trackPaint,
      );
    }
  }

  void _drawGridLines(Canvas canvas, double cellSize) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0;

    // Draw vertical lines
    for (int i = 0; i <= gridSize; i++) {
      final x = i * cellSize;
      canvas.drawLine(Offset(x, 0), Offset(x, gridSize * cellSize), paint);
    }

    // Draw horizontal lines
    for (int i = 0; i <= gridSize; i++) {
      final y = i * cellSize;
      canvas.drawLine(Offset(0, y), Offset(gridSize * cellSize, y), paint);
    }
  }

  void _drawSafeSquares(Canvas canvas, double cellSize) {
    // Define safe squares where tokens cannot be captured
    final safeSquares = [
      (7, 3),
      (3, 7),
      (3, 9),
      (7, 11),
      (9, 13),
      (11, 9),
      (13, 7),
      (9, 3),
    ];

    for (final (row, col) in safeSquares) {
      final cx = (col - 0.5) * cellSize;
      final cy = (row - 0.5) * cellSize;
      _drawSafeSquare(canvas, cx, cy, cellSize * 0.4);
    }
  }

  void _drawSafeSquare(Canvas canvas, double cx, double cy, double size) {
    // Draw colored circle for safe square
    final safePaint = Paint()
      ..color = starColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(cx, cy), size, safePaint);

    // Draw border around safe square
    final borderPaint = Paint()
      ..color = Colors.orange[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(Offset(cx, cy), size, borderPaint);

    // Draw star pattern inside safe square
    _drawStar(canvas, cx, cy, size * 0.6);
  }

  void _drawStar(Canvas canvas, double cx, double cy, double size) {
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final r = (i % 2 == 0) ? size : size * 0.4;
      final angle = (i * pi / 5) - (pi / 2);
      final x = cx + r * cos(angle);
      final y = cy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  void _drawCenterTriangles(Canvas canvas, double cellSize) {
    final cx = (8 - 0.5) * cellSize;
    final cy = (8 - 0.5) * cellSize;
    final half = cellSize / 2;

    // Draw four colored triangles pointing to each home
    _drawTriangle(
      canvas,
      cx,
      cy - half,
      cx - half,
      cy,
      cx + half,
      cy,
      redColor,
    );
    _drawTriangle(
      canvas,
      cx - half,
      cy,
      cx,
      cy - half,
      cx,
      cy + half,
      greenColor,
    );
    _drawTriangle(
      canvas,
      cx,
      cy + half,
      cx - half,
      cy,
      cx + half,
      cy,
      yellowColor,
    );
    _drawTriangle(
      canvas,
      cx + half,
      cy,
      cx,
      cy - half,
      cx,
      cy + half,
      blueColor,
    );

    // Draw center circle
    canvas.drawCircle(
      Offset(cx, cy),
      cellSize * 0.15,
      Paint()..color = Colors.black,
    );
  }

  void _drawTriangle(
    Canvas canvas,
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
    Color color,
  ) {
    final path = Path()
      ..moveTo(x1, y1)
      ..lineTo(x2, y2)
      ..lineTo(x3, y3)
      ..close();

    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _drawHomeStretches(Canvas canvas, double cellSize) {
    final stretchPaint = Paint()..style = PaintingStyle.fill;

    // Red home stretch (left side, going up)
    stretchPaint.color = redColor.withOpacity(0.3);
    for (int row = 2; row <= 6; row++) {
      canvas.drawRect(
        Rect.fromLTWH(7 * cellSize, (row - 1) * cellSize, cellSize, cellSize),
        stretchPaint,
      );
    }

    // Green home stretch (top side, going right)
    stretchPaint.color = greenColor.withOpacity(0.3);
    for (int col = 8; col <= 9; col++) {
      canvas.drawRect(
        Rect.fromLTWH((col - 1) * cellSize, 7 * cellSize, cellSize, cellSize),
        stretchPaint,
      );
    }

    // Yellow home stretch (right side, going down)
    stretchPaint.color = yellowColor.withOpacity(0.3);
    for (int row = 9; row <= 13; row++) {
      canvas.drawRect(
        Rect.fromLTWH(7 * cellSize, (row - 1) * cellSize, cellSize, cellSize),
        stretchPaint,
      );
    }

    // Blue home stretch (bottom side, going left)
    stretchPaint.color = blueColor.withOpacity(0.3);
    for (int col = 2; col <= 7; col++) {
      canvas.drawRect(
        Rect.fromLTWH((col - 1) * cellSize, 7 * cellSize, cellSize, cellSize),
        stretchPaint,
      );
    }
  }

  void _drawBorder(Canvas canvas, Size size) {
    // Draw main board border with rounded effect
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawRect(
      Rect.fromLTWH(2, 2, size.width - 4, size.height - 4),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(EnhancedLudoBoardPainter oldDelegate) => false;
}
