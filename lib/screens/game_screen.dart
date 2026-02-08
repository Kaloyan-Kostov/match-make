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
      backgroundColor: AppTheme.darkNavy,
      appBar: AppBar(
        backgroundColor: AppTheme.darkNavy,
        elevation: 0,
        title: const Text(
          'MatchMake!',
          style: TextStyle(
            color: AppTheme.mintGreen,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
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

            const SizedBox(height: 16),

            // Blurred profile image
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: BlurredProfileImage(revealProgress: _myProgress),
            ),

            const SizedBox(height: 24),

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
            Text(
              'Round ${_currentRound + 1} of ${_gameRounds.length}',
              style: TextStyle(
                color: AppTheme.mintGreen.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_waitingForThem)
              Row(
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.mintGreen.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Waiting for them...',
                    style: TextStyle(
                      color: AppTheme.slate.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
          ],
        ),

        const SizedBox(height: 8),

        // Prompt
        Text(
          roundData['prompt'],
          style: const TextStyle(
            color: AppTheme.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        // Word grid (Wrap layout)
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(options.length, (index) {
                    return _buildWordTag(
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

  Widget _buildWordTag({
    required String text,
    required int index,
    required bool isMySelection,
    required bool isTheirSelection,
  }) {
    Color bgColor = AppTheme.lightNavy;
    Color textColor = AppTheme.white;
    Color borderColor = AppTheme.mintGreen.withValues(alpha: 0.3);

    if (isMySelection) {
      bgColor = AppTheme.mintGreen;
      textColor = AppTheme.darkNavy;
      borderColor = AppTheme.mintGreen;
    }

    if (isTheirSelection && !isMySelection) {
      borderColor = AppTheme.slate;
    }

    return GestureDetector(
      onTap: _showResult ? null : () => _handleOptionSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
          boxShadow: isMySelection
              ? [
                  BoxShadow(
                    color: AppTheme.mintGreen.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppTheme.buttonShadow,
                    offset: const Offset(0, 3),
                    blurRadius: 0,
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
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            // Show ghost icon for THEM's selection
            if (isTheirSelection) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.person_outline,
                size: 16,
                color: isMySelection ? AppTheme.darkNavy : AppTheme.slate,
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
        color: AppTheme.lightNavy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMatch
              ? AppTheme.mintGreen.withValues(alpha: 0.5)
              : AppTheme.slate.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isMatch
                  ? AppTheme.mintGreen.withValues(alpha: 0.2)
                  : AppTheme.slate.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isMatch ? Icons.favorite : Icons.person_outline,
              color: isMatch ? AppTheme.mintGreen : AppTheme.slate,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMatch ? 'It\'s a match!' : 'They selected:',
                  style: TextStyle(
                    color: isMatch ? AppTheme.mintGreen : AppTheme.slate,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  options[_theirSelectedOption!],
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (isMatch)
            Icon(
              Icons.check_circle,
              color: AppTheme.mintGreen,
              size: 24,
            ),
        ],
      ),
    );
  }

  Widget _buildGameComplete() {
    final isFullReveal = _myProgress == 5 && _theirProgress == 5;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isFullReveal ? Icons.favorite : Icons.favorite_border,
          color: AppTheme.mintGreen,
          size: 64,
        ),
        const SizedBox(height: 16),
        Text(
          isFullReveal ? 'Photo Revealed!' : 'Game Complete!',
          style: const TextStyle(
            color: AppTheme.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'You revealed ${_myProgress * 20}% of the photo',
          style: const TextStyle(
            color: AppTheme.slate,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),

        // Match summary
        if (_roundHistory.isNotEmpty) ...[
          Text(
            '${_roundHistory.where((r) => r['mySelection'] == r['theirSelection']).length} of ${_roundHistory.length} answers matched!',
            style: TextStyle(
              color: AppTheme.mintGreen.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
        ],

        const SizedBox(height: 32),
        GameButton(
          text: 'Play Again',
          onPressed: _resetGame,
        ),
      ],
    );
  }
}
