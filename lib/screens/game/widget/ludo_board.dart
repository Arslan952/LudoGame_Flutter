import 'package:flutter/material.dart';

import '../../../models/game_model.dart';

class LudoBoardPainter extends CustomPainter {
  final GameModel? gameState;
  final int? selectedTokenIndex;
  final String? currentPlayerId;

  LudoBoardPainter({
    this.gameState,
    this.selectedTokenIndex,
    this.currentPlayerId,
  });

  static const int BOARD_SIZE = 15;
  static const double PATH_SIZE = 52;
  static const double HOME_STRETCH = 6;

  // Safe zone positions for each player
  static const Map<int, List<int>> SAFE_POSITIONS = {
    0: [0, 8, 13, 21, 26, 34, 39, 47],
    1: [14, 22, 27, 35, 40, 48, 1, 9],
    2: [13, 21, 26, 34, 39, 47, 6, 14],
    3: [26, 34, 39, 47, 4, 12, 17, 25],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / BOARD_SIZE;

    // Draw board background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.yellow.shade100,
    );

    // Draw grid
    _drawGrid(canvas, size, cellSize);

    // Draw home zones
    _drawHomeZones(canvas, size, cellSize);

    // Draw safe zones
    _drawSafeZones(canvas, size, cellSize);

    // Draw tokens
    if (gameState != null) {
      _drawTokens(canvas, size, cellSize);
    }
  }

  void _drawGrid(Canvas canvas, Size size, double cellSize) {
    final paint = Paint()
      ..color = Colors.black26
      ..strokeWidth = 0.5;

    for (int i = 0; i <= BOARD_SIZE; i++) {
      canvas.drawLine(
        Offset(i * cellSize, 0),
        Offset(i * cellSize, size.height),
        paint,
      );
      canvas.drawLine(
        Offset(0, i * cellSize),
        Offset(size.width, i * cellSize),
        paint,
      );
    }
  }

  void _drawHomeZones(Canvas canvas, Size size, double cellSize) {
    final colors = [Colors.red, Colors.green, Colors.yellow, Colors.blue];

    // Top-left (Red)
    _drawHomeArea(canvas, 0, 0, colors[0], cellSize);

    // Top-right (Green)
    _drawHomeArea(canvas, BOARD_SIZE - 4, 0, colors[1], cellSize);

    // Bottom-right (Yellow)
    _drawHomeArea(canvas, BOARD_SIZE - 4, BOARD_SIZE - 4, colors[2], cellSize);

    // Bottom-left (Blue)
    _drawHomeArea(canvas, 0, BOARD_SIZE - 4, colors[3], cellSize);
  }

  void _drawHomeArea(
    Canvas canvas,
    int startCol,
    int startRow,
    Color color,
    double cellSize,
  ) {
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        final rect = Rect.fromLTWH(
          (startCol + j) * cellSize + 2,
          (startRow + i) * cellSize + 2,
          cellSize - 4,
          cellSize - 4,
        );

        canvas.drawRect(rect, Paint()..color = color.withValues(alpha: 0.2));

        canvas.drawRect(
          rect,
          Paint()
            ..color = color.withValues(alpha: 0.5)
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke,
        );
      }
    }
  }

  void _drawSafeZones(Canvas canvas, Size size, double cellSize) {
    final safePaint = Paint()
      ..color = Colors.purple.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    const safeSquares = [0, 8, 13, 21, 26, 34, 39, 47];

    for (int pos in safeSquares) {
      final col = pos % BOARD_SIZE;
      final row = pos ~/ BOARD_SIZE;

      canvas.drawCircle(
        Offset(col * cellSize + cellSize / 2, row * cellSize + cellSize / 2),
        cellSize / 3,
        safePaint,
      );
    }
  }

  void _drawTokens(Canvas canvas, Size size, double cellSize) {
    final colors = [Colors.red, Colors.green, Colors.yellow, Colors.blue];

    for (
      int playerIdx = 0;
      playerIdx < gameState!.playerIds.length;
      playerIdx++
    ) {
      final playerId = gameState!.playerIds[playerIdx];
      final positions = gameState!.tokenPositions[playerId] ?? [];
      final playerColor = colors[playerIdx];

      for (int tokenIdx = 0; tokenIdx < positions.length; tokenIdx++) {
        final position = positions[tokenIdx];

        if (position >= 0 && position < PATH_SIZE + HOME_STRETCH) {
          final offset = _getTokenCoordinates(
            position,
            playerIdx,
            tokenIdx,
            cellSize,
            size,
          );

          _drawToken(
            canvas,
            offset,
            playerColor,
            tokenIdx + 1,
            isSelected:
                currentPlayerId == playerId && selectedTokenIndex == tokenIdx,
          );
        } else if (position == -1) {
          final homeOffset = _getHomeTokenCoordinates(
            playerIdx,
            tokenIdx,
            cellSize,
          );
          _drawToken(
            canvas,
            homeOffset,
            playerColor,
            tokenIdx + 1,
            isHome: true,
            isSelected:
                currentPlayerId == playerId && selectedTokenIndex == tokenIdx,
          );
        }
      }
    }
  }

  Offset _getHomeTokenCoordinates(
    int playerIdx,
    int tokenIdx,
    double cellSize,
  ) {
    final homePositions = {
      0: [
        Offset(cellSize + cellSize / 3, cellSize + cellSize / 3),
        Offset(cellSize * 2, cellSize + cellSize / 3),
        Offset(cellSize + cellSize / 3, cellSize * 2),
        Offset(cellSize * 2, cellSize * 2),
      ],
      1: [
        Offset(cellSize * 12, cellSize + cellSize / 3),
        Offset(cellSize * 13, cellSize + cellSize / 3),
        Offset(cellSize * 12, cellSize * 2),
        Offset(cellSize * 13, cellSize * 2),
      ],
      2: [
        Offset(cellSize * 12, cellSize * 12),
        Offset(cellSize * 13, cellSize * 12),
        Offset(cellSize * 12, cellSize * 13),
        Offset(cellSize * 13, cellSize * 13),
      ],
      3: [
        Offset(cellSize + cellSize / 3, cellSize * 12),
        Offset(cellSize * 2, cellSize * 12),
        Offset(cellSize + cellSize / 3, cellSize * 13),
        Offset(cellSize * 2, cellSize * 13),
      ],
    };

    return homePositions[playerIdx]?[tokenIdx] ??
        Offset(cellSize * 7, cellSize * 7);
  }

  Offset _getTokenCoordinates(
    int position,
    int playerIdx,
    int tokenIdx,
    double cellSize,
    Size size,
  ) {
    // Convert position to board coordinates
    double x = 0, y = 0;

    if (position < 14) {
      x = position * cellSize + cellSize / 2;
      y = 6 * cellSize + cellSize / 2;
    } else if (position < 28) {
      x = 13 * cellSize + cellSize / 2;
      y = (6 - (position - 14)) * cellSize + cellSize / 2;
    } else if (position < 42) {
      x = (13 - (position - 28)) * cellSize + cellSize / 2;
      y = 0 + cellSize / 2;
    } else {
      x = 0 + cellSize / 2;
      y = (position - 42) * cellSize + cellSize / 2;
    }

    // Add small offsets so tokens don't overlap
    double offsetX = (tokenIdx % 2 == 0 ? -1 : 1) * cellSize / 6;
    double offsetY = (tokenIdx < 2 ? -1 : 1) * cellSize / 6;

    return Offset(x + offsetX, y + offsetY);
  }

  void _drawToken(
    Canvas canvas,
    Offset offset,
    Color color,
    int number, {
    bool isSelected = false,
    bool isHome = false,
  }) {
    const tokenRadius = 10.0;

    // Draw token background
    canvas.drawCircle(offset, tokenRadius, Paint()..color = color);

    // Draw selection border
    if (isSelected) {
      canvas.drawCircle(
        offset,
        tokenRadius + 3,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke,
      );
    }

    // Draw border
    canvas.drawCircle(
      offset,
      tokenRadius,
      Paint()
        ..color = Colors.black
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    // Draw number
    final textPainter = TextPainter(
      text: TextSpan(
        text: number.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      offset - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(LudoBoardPainter oldDelegate) {
    return gameState != oldDelegate.gameState ||
        selectedTokenIndex != oldDelegate.selectedTokenIndex ||
        currentPlayerId != oldDelegate.currentPlayerId;
  }
}
