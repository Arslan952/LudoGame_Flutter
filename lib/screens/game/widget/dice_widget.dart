import 'package:flutter/material.dart';

class DiceWidget extends StatefulWidget {
  final int value;
  final VoidCallback? onRoll;
  final bool isRolling;
  final bool isEnabled;
  final Color? diceColor;

  const DiceWidget({
    super.key,
    required this.value,
    this.onRoll,
    this.isRolling = false,
    this.isEnabled = true,
    this.diceColor,
  });

  @override
  State<DiceWidget> createState() => _DiceWidgetState();
}

class _DiceWidgetState extends State<DiceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(DiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Start rolling when isRolling changes from false to true
    if (widget.isRolling && !oldWidget.isRolling) {
      _rotationController.repeat();
    }
    // Stop rolling when isRolling changes from true to false
    else if (!widget.isRolling && oldWidget.isRolling) {
      _rotationController.stop();
      _rotationController.reset();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color baseColor = widget.diceColor ?? Colors.blue;
    final bool canRoll =
        widget.isEnabled && !widget.isRolling && widget.onRoll != null;

    debugPrint(
      'DEBUG DICE: isRolling=${widget.isRolling}, isEnabled=${widget.isEnabled}, canRoll=$canRoll',
    );

    return GestureDetector(
      onTap: canRoll
          ? () {
              debugPrint('DEBUG: Dice tapped, calling onRoll');
              widget.onRoll!();
            }
          : null,
      child: RotationTransition(
        turns: _rotationController,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [baseColor.withValues(alpha: 0.8), baseColor],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: baseColor.withValues(alpha: 0.3),
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
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : _buildDiceFace(widget.value),
              ),
            ),
          ),
        ),
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
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }

  Widget _buildFaceOne(double dotSize) {
    return Center(child: _buildDot(dotSize));
  }

  Widget _buildFaceTwo(double dotSize) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Align(alignment: Alignment.topRight, child: _buildDot(dotSize)),
        Align(alignment: Alignment.bottomLeft, child: _buildDot(dotSize)),
      ],
    );
  }

  Widget _buildFaceThree(double dotSize) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Align(alignment: Alignment.topRight, child: _buildDot(dotSize)),
        Center(child: _buildDot(dotSize)),
        Align(alignment: Alignment.bottomLeft, child: _buildDot(dotSize)),
      ],
    );
  }

  Widget _buildFaceFour(double dotSize) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [_buildDot(dotSize), _buildDot(dotSize)],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [_buildDot(dotSize), _buildDot(dotSize)],
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
          children: [_buildDot(dotSize), _buildDot(dotSize)],
        ),
        Center(child: _buildDot(dotSize)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [_buildDot(dotSize), _buildDot(dotSize)],
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
