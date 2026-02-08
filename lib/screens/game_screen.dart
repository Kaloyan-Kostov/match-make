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
  int _revealProgress = 0; // 0-5
  int _currentRound = 0;
  int? _selectedOption;
  bool _showResult = false;

  // Sample game data - each round has a prompt and options
  final List<Map<String, dynamic>> _gameRounds = [
    {
      'prompt': 'The perfect first date is...',
      'options': ['Adventure', 'Coffee chat', 'Fine dining', 'Movie night', 'Stargazing'],
      'correctIndex': 0, // For demo, first option is always "correct"
    },
    {
      'prompt': 'My ideal weekend involves...',
      'options': ['Hiking', 'Netflix', 'Brunch', 'Gaming', 'Reading'],
      'correctIndex': 1,
    },
    {
      'prompt': 'I value most in a partner...',
      'options': ['Humor', 'Ambition', 'Kindness', 'Intelligence', 'Loyalty'],
      'correctIndex': 2,
    },
    {
      'prompt': 'My love language is...',
      'options': ['Words', 'Touch', 'Gifts', 'Time', 'Acts'],
      'correctIndex': 3,
    },
    {
      'prompt': 'In 5 years, I see myself...',
      'options': ['Traveling', 'Settled', 'Growing', 'Exploring', 'Creating'],
      'correctIndex': 4,
    },
  ];

  Map<String, dynamic> get _currentRoundData {
    if (_currentRound >= _gameRounds.length) {
      return _gameRounds.last;
    }
    return _gameRounds[_currentRound];
  }

  void _handleOptionSelected(int index) {
    if (_showResult) return;

    setState(() {
      _selectedOption = index;
      _showResult = true;
    });

    // Delay before moving to next round
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      setState(() {
        _revealProgress = (_revealProgress + 1).clamp(0, 5);
        _currentRound++;
        _selectedOption = null;
        _showResult = false;
      });
    });
  }

  void _resetGame() {
    setState(() {
      _revealProgress = 0;
      _currentRound = 0;
      _selectedOption = null;
      _showResult = false;
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
            // Progress bar
            MatchProgressBar(currentProgress: _revealProgress),

            const SizedBox(height: 16),

            // Blurred profile image
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: BlurredProfileImage(revealProgress: _revealProgress),
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
        Text(
          'Round ${_currentRound + 1} of ${_gameRounds.length}',
          style: TextStyle(
            color: AppTheme.mintGreen.withValues(alpha: 0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
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

        // Options
        Expanded(
          child: ListView.separated(
            itemCount: options.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return GameButton(
                text: options[index],
                isSelected: _selectedOption == index,
                isCorrect: index == roundData['correctIndex'],
                showResult: _showResult,
                onPressed: () => _handleOptionSelected(index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGameComplete() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _revealProgress == 5 ? Icons.favorite : Icons.favorite_border,
          color: AppTheme.mintGreen,
          size: 64,
        ),
        const SizedBox(height: 16),
        Text(
          _revealProgress == 5 ? 'Photo Revealed!' : 'Game Complete!',
          style: const TextStyle(
            color: AppTheme.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'You revealed ${_revealProgress * 20}% of the photo',
          style: TextStyle(
            color: AppTheme.slate,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 32),
        GameButton(
          text: 'Play Again',
          onPressed: _resetGame,
        ),
      ],
    );
  }
}
