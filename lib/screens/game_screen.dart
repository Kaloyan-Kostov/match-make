import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/match_progress_bar.dart';
import '../widgets/blurred_profile_image.dart';
import '../widgets/game_button.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _myProgress = 0; // 0-5 (my rounds completed)
  int _theirProgress = 0; // 0-5 (their rounds completed)
  int _currentRound = 0;
  int? _selectedOption;
  int? _theirSelectedOption; // What THEM selected
  bool _showResult = false;
  bool _waitingForThem = false;

  final Random _random = Random();

  // Sample game data - each round has a prompt and options
  final List<Map<String, dynamic>> _gameRounds = [
    {
      'prompt': 'The perfect first date is...',
      'options': ['Adventure', 'Coffee chat', 'Fine dining', 'Movie night', 'Stargazing'],
    },
    {
      'prompt': 'My ideal weekend involves...',
      'options': ['Hiking', 'Netflix', 'Brunch', 'Gaming', 'Reading'],
    },
    {
      'prompt': 'I value most in a partner...',
      'options': ['Humor', 'Ambition', 'Kindness', 'Intelligence', 'Loyalty'],
    },
    {
      'prompt': 'My love language is...',
      'options': ['Words', 'Touch', 'Gifts', 'Time', 'Acts'],
    },
    {
      'prompt': 'In 5 years, I see myself...',
      'options': ['Traveling', 'Settled', 'Growing', 'Exploring', 'Creating'],
    },
  ];

  // Track selections for round summary
  final List<Map<String, int>> _roundHistory = [];

  Map<String, dynamic> get _currentRoundData {
    if (_currentRound >= _gameRounds.length) {
      return _gameRounds.last;
    }
    return _gameRounds[_currentRound];
  }

  int get _theirBlurLevel => 5 - _myProgress; // Blur decreases as I progress

  void _handleOptionSelected(int index) {
    if (_showResult || _waitingForThem) return;

    setState(() {
      _selectedOption = index;
      _showResult = true;
      _myProgress = (_myProgress + 1).clamp(0, 5);
      _waitingForThem = true;
    });

    // Simulate THEM making a selection after a delay
    Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)), () {
      if (!mounted) return;

      setState(() {
        _theirSelectedOption = _random.nextInt(_currentRoundData['options'].length);
        _theirProgress = (_theirProgress + 1).clamp(0, 5);
        _waitingForThem = false;

        // Record round history
        _roundHistory.add({
          'mySelection': _selectedOption!,
          'theirSelection': _theirSelectedOption!,
        });
      });

      // Move to next round after showing their selection
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;

        setState(() {
          _currentRound++;
          _selectedOption = null;
          _theirSelectedOption = null;
          _showResult = false;
        });
      });
    });
  }

  void _resetGame() {
    setState(() {
      _myProgress = 0;
      _theirProgress = 0;
      _currentRound = 0;
      _selectedOption = null;
      _theirSelectedOption = null;
      _showResult = false;
      _waitingForThem = false;
      _roundHistory.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isGameComplete = _currentRound >= _gameRounds.length;

    return Scaffold(
      backgroundColor: AppTheme.deepPlum,
      appBar: AppBar(
        backgroundColor: AppTheme.deepPlum,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite,
              color: AppTheme.heartRed,
              size: 28,
            ),
            const SizedBox(width: 8),
            const Text(
              'MatchMake!',
              style: TextStyle(
                color: AppTheme.cream,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Dual Progress bar with avatars
            MatchProgressBar(
              myProgress: _myProgress,
              theirProgress: _theirProgress,
              theirBlurLevel: _theirBlurLevel,
            ),

            const SizedBox(height: 12),

            // Blurred profile image
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: BlurredProfileImage(revealProgress: _myProgress),
            ),

            const SizedBox(height: 20),

            // Game content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: isGameComplete
                    ? _buildGameComplete()
                    : _buildGameRound(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameRound() {
    final roundData = _currentRoundData;
    final options = roundData['options'] as List<String>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Round indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.warmBerry,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Round ${_currentRound + 1} of ${_gameRounds.length}',
                style: TextStyle(
                  color: AppTheme.coralPink.withValues(alpha: 0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (_waitingForThem)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.warmBerry,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.coralPink.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Their turn...',
                      style: TextStyle(
                        color: AppTheme.softCream.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),

        const SizedBox(height: 14),

        // Prompt
        Text(
          roundData['prompt'],
          style: const TextStyle(
            color: AppTheme.cream,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),

        const SizedBox(height: 20),

        // Word cloud (Wrap layout with soft pills)
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(options.length, (index) {
                    return _buildWordPill(
                      text: options[index],
                      index: index,
                      isMySelection: _selectedOption == index,
                      isTheirSelection: _theirSelectedOption == index,
                    );
                  }),
                ),

                // Round summary - show THEM's selection
                if (_theirSelectedOption != null) ...[
                  const SizedBox(height: 24),
                  _buildRoundSummary(options),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWordPill({
    required String text,
    required int index,
    required bool isMySelection,
    required bool isTheirSelection,
  }) {
    Color bgColor = AppTheme.softPlum;
    Color textColor = AppTheme.cream;
    Color borderColor = AppTheme.lightPlum;
    Color shadowColor = AppTheme.pillShadow;

    if (isMySelection) {
      bgColor = AppTheme.coralPink;
      textColor = AppTheme.deepPlum;
      borderColor = AppTheme.coralPink;
      shadowColor = const Color(0xFFB85A50);
    }

    if (isTheirSelection && !isMySelection) {
      borderColor = AppTheme.mutedText;
    }

    return GestureDetector(
      onTap: _showResult ? null : () => _handleOptionSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
            if (isMySelection)
              BoxShadow(
                color: AppTheme.coralPink.withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            // Show heart icon for THEM's selection
            if (isTheirSelection) ...[
              const SizedBox(width: 8),
              Icon(
                isMySelection ? Icons.favorite : Icons.favorite_border,
                size: 16,
                color: isMySelection ? AppTheme.deepPlum : AppTheme.mutedText,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRoundSummary(List<String> options) {
    final isMatch = _selectedOption == _theirSelectedOption;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warmBerry,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isMatch
              ? AppTheme.heartRed.withValues(alpha: 0.5)
              : AppTheme.softPlum,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.pillShadow.withValues(alpha: 0.5),
            offset: const Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isMatch
                  ? AppTheme.heartRed.withValues(alpha: 0.2)
                  : AppTheme.softPlum.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isMatch ? Icons.favorite : Icons.person_outline,
              color: isMatch ? AppTheme.heartRed : AppTheme.mutedText,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMatch ? 'It\'s a match!' : 'They selected:',
                  style: TextStyle(
                    color: isMatch ? AppTheme.heartRed : AppTheme.mutedText,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  options[_theirSelectedOption!],
                  style: const TextStyle(
                    color: AppTheme.cream,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (isMatch)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.heartRed.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite,
                color: AppTheme.heartRed,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGameComplete() {
    final isFullReveal = _myProgress == 5 && _theirProgress == 5;
    final matchCount = _roundHistory
        .where((r) => r['mySelection'] == r['theirSelection'])
        .length;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Big heart icon
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.heartRed.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isFullReveal ? Icons.favorite : Icons.favorite_border,
            color: AppTheme.heartRed,
            size: 72,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          isFullReveal ? 'Photo Revealed!' : 'Game Complete!',
          style: const TextStyle(
            color: AppTheme.cream,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'You revealed ${_myProgress * 20}% of their photo',
          style: const TextStyle(
            color: AppTheme.softCream,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),

        // Match summary
        if (_roundHistory.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.warmBerry,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.favorite,
                  color: AppTheme.heartRed,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '$matchCount of ${_roundHistory.length} answers matched!',
                  style: TextStyle(
                    color: AppTheme.coralPink,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 36),
        SizedBox(
          width: double.infinity,
          child: GameButton(
            text: 'Play Again',
            onPressed: _resetGame,
          ),
        ),
      ],
    );
  }
}
