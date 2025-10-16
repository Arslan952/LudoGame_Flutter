import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/authProvider.dart';
import '../../provider/gameProvider.dart';

class GameBoardScreen extends StatefulWidget {
  const GameBoardScreen({Key? key}) : super(key: key);

  @override
  State<GameBoardScreen> createState() => _GameBoardScreenState();
}

class _GameBoardScreenState extends State<GameBoardScreen> {
  int _diceValue = 0;
  bool _diceRolled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ludo Game')),
      body: Consumer2<GameProvider, AuthProvider>(
        builder: (context, gameProvider, authProvider, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPlayerInfo('Player 1', Colors.red, true),
                    _buildPlayerInfo('Player 2', Colors.green, false),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade100,
                    border: Border.all(width: 4, color: Colors.brown),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomPaint(
                    painter: LudoBoardPainter(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _diceRolled ? null : _rollDice,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(width: 3, color: Colors.black),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            _diceValue.toString(),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _diceRolled ? _endTurn : null,
                      child: const Text('End Turn'),
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

  Widget _buildPlayerInfo(String name, Color color, bool isTurn) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(
          color: color,
          width: isTurn ? 3 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          CircleAvatar(backgroundColor: color, radius: 24),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          if (isTurn)
            const Text(
              'Your Turn',
              style: TextStyle(color: Colors.green, fontSize: 12),
            ),
        ],
      ),
    );
  }

  void _rollDice() {
    setState(() {
      _diceValue = (DateTime.now().millisecondsSinceEpoch % 6) + 1;
      _diceRolled = true;
    });
  }

  void _endTurn() {
    setState(() {
      _diceRolled = false;
      _diceValue = 0;
    });
  }
}

class LudoBoardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke;

    final squareSize = size.width / 15;

    for (int i = 0; i < 15; i++) {
      for (int j = 0; j < 15; j++) {
        canvas.drawRect(
          Rect.fromLTWH(i * squareSize, j * squareSize, squareSize, squareSize),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}