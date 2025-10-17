import 'package:flutter/material.dart';
import 'dart:math' as math;

class DiceWidget extends StatefulWidget {
  final int value;
  final VoidCallback? onRoll;
  final bool isRolling;
  final bool isEnabled;
  final Color? diceColor;

  const DiceWidget({
    Key? key,
    required this.value,
    this.onRoll,
    this.isRolling = false,
    this.isEnabled = true,
    this.diceColor,
  }) : super(key: key);

  @override
  State<DiceWidget> createState() => _DiceWidgetState();
}

class _DiceWidgetState extends State<DiceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(DiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRolling && !oldWidget.isRolling) {
      _startRolling();
    } else if (!widget.isRolling && oldWidget.isRolling) {
      _stopRolling();
    }
  }

  void _startRolling() {
    _rotationController.repeat();
  }

  void _stopRolling() {
    _rotationController.stop();
    _rotationController.reset();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color baseColor = widget.diceColor ?? Colors.blue;
    final bool canRoll = widget.isEnabled && !widget.isRolling && widget.onRoll != null;

    return GestureDetector(
      onTap: canRoll ? widget.onRoll : null,
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: widget.isRolling ? _rotationAnimation.value : 0,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    baseColor.withOpacity(0.8),
                    baseColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: baseColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: canRoll ? widget.onRoll : null,
                  child: Center(
                    child: widget.isRolling
                        ? const SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : _buildDiceFace(widget.value),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDiceFace(int value) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.maxWidth;
          final dotSize = size / 6;

          switch (value) {
            case 1:
              return _buildFaceOne(dotSize);
            case 2:
              return _buildFaceTwo(dotSize);
            case 3:
              return _buildFaceThree(dotSize);
            case 4:
              return _buildFaceFour(dotSize);
            case 5:
              return _buildFaceFive(dotSize);
            case 6:
              return _buildFaceSix(dotSize);
            default:
              return _buildFaceOne(dotSize);
          }
        },
      ),
    );
  }

  Widget _buildDot(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }

  Widget _buildFaceOne(double dotSize) {
    return Center(
      child: _buildDot(dotSize),
    );
  }

  Widget _buildFaceTwo(double dotSize) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Align(
          alignment: Alignment.topRight,
          child: _buildDot(dotSize),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: _buildDot(dotSize),
        ),
      ],
    );
  }

  Widget _buildFaceThree(double dotSize) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Align(
          alignment: Alignment.topRight,
          child: _buildDot(dotSize),
        ),
        Center(
          child: _buildDot(dotSize),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: _buildDot(dotSize),
        ),
      ],
    );
  }

  Widget _buildFaceFour(double dotSize) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDot(dotSize),
            _buildDot(dotSize),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDot(dotSize),
            _buildDot(dotSize),
          ],
        ),
      ],
    );
  }

  Widget _buildFaceFive(double dotSize) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDot(dotSize),
            _buildDot(dotSize),
          ],
        ),
        Center(
          child: _buildDot(dotSize),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDot(dotSize),
            _buildDot(dotSize),
          ],
        ),
      ],
    );
  }

  Widget _buildFaceSix(double dotSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDot(dotSize),
            _buildDot(dotSize),
            _buildDot(dotSize),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDot(dotSize),
            _buildDot(dotSize),
            _buildDot(dotSize),
          ],
        ),
      ],
    );
  }
}