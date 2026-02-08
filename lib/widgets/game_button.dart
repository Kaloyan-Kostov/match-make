import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GameButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isSelected;
  final bool isCorrect;
  final bool showResult;

  const GameButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSelected = false,
    this.isCorrect = false,
    this.showResult = false,
  });

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> {
  bool _isPressed = false;

  Color get _buttonColor {
    if (widget.showResult && widget.isSelected) {
      return widget.isCorrect
          ? AppTheme.coralPink
          : const Color(0xFFE57373);
    }
    if (widget.isSelected) {
      return AppTheme.coralPink;
    }
    return AppTheme.softPlum;
  }

  Color get _shadowColor {
    if (widget.showResult && widget.isSelected) {
      return widget.isCorrect
          ? const Color(0xFFB85A50)
          : const Color(0xFFAF4448);
    }
    if (widget.isSelected) {
      return const Color(0xFFB85A50);
    }
    return AppTheme.pillShadow;
  }

  Color get _textColor {
    if (widget.isSelected || (widget.showResult && widget.isSelected)) {
      return AppTheme.deepPlum;
    }
    return AppTheme.cream;
  }

  Color get _borderColor {
    if (widget.isSelected) {
      return AppTheme.coralPink;
    }
    return AppTheme.lightPlum;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: EdgeInsets.only(
          top: _isPressed ? 4 : 0,
          bottom: _isPressed ? 0 : 4,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            color: _buttonColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _borderColor,
              width: 2,
            ),
            boxShadow: _isPressed
                ? []
                : [
                    BoxShadow(
                      color: _shadowColor,
                      offset: const Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ],
          ),
          child: Text(
            widget.text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
