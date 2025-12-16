// lib/components/slide_stance_button.dart
import 'package:flutter/material.dart';

class SlideStanceButton extends StatefulWidget {
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;

  const SlideStanceButton({
    super.key,
    required this.label,
    required this.gradient,
    required this.onTap,
    TextStyle? textStyle,
    TextStyle? labelStyle,
  });

  @override
  State<SlideStanceButton> createState() => _SlideStanceButtonState();
}

class _SlideStanceButtonState extends State<SlideStanceButton>
    with SingleTickerProviderStateMixin {
  double _percent = 0.0; // 0.0 = start, 1.0 = fully right
  String _displayLabel;
  late AnimationController _resetController;

  static const _threshold = 0.7;

  _SlideStanceButtonState() : _displayLabel = '';

  @override
  void initState() {
    super.initState();
    _displayLabel = widget.label;
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        setState(() {
          _percent = _resetController.value;
        });
      });
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  void _handlePanUpdate(DragUpdateDetails details, double maxWidth) {
    setState(() {
      _percent = (_percent + details.delta.dx / maxWidth).clamp(0.0, 1.0);
    });
  }

  void _handlePanEnd() {
    if (_percent >= _threshold) {
      // confirmed
      setState(() => _displayLabel = 'Done');
      widget.onTap();
      _resetController.value = 1.0;
    } else {
      setState(() => _displayLabel = 'Release');
      Future.delayed(const Duration(milliseconds: 500), () {
        _resetController.reverse(from: _percent).then((_) {
          setState(() => _displayLabel = widget.label);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final maxW = constraints.maxWidth - 56 - 12;
      return GestureDetector(
        onHorizontalDragUpdate: (d) => _handlePanUpdate(d, maxW),
        onHorizontalDragEnd: (_) => _handlePanEnd(),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradient,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.black26, width: 1),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Centered label
              Positioned.fill(
                child: Center(
                  child: Text(
                    _displayLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Draggable thumb
              Positioned(
                left: 6 + _percent * maxW,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.double_arrow,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
