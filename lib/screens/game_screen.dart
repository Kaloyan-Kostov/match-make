import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/match_progress_bar.dart';
import '../widgets/blurred_profile_image.dart';
import '../widgets/frosted_glass_button.dart';
import '../widgets/game_button.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  int _myProgress = 0;
  int _theirProgress = 0;
  int _currentRound = 0;
  int? _selectedOption;
  int? _theirSelectedOption;
  bool _showResult = false;
  bool _waitingForThem = false;

  // Game scoring
  int _vibeScore = 0;
  int _comboCount = 0;
  DateTime? _lastSelectionTime;
  bool _showComboBonus = false;

  final Random _random = Random();

  late AnimationController _scorePopController;
  late Animation<double> _scorePopAnimation;

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

  final List<Map<String, int>> _roundHistory = [];

  @override
  void initState() {
    super.initState();
    _scorePopController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scorePopAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _scorePopController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _scorePopController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _currentRoundData {
    if (_currentRound >= _gameRounds.length) {
      return _gameRounds.last;
    }
    return _gameRounds[_currentRound];
  }

  int get _theirBlurLevel => 5 - _myProgress;

  void _handleOptionSelected(int index) {
    if (_showResult || _waitingForThem) return;

    // Calculate speed bonus
    final now = DateTime.now();
    int speedBonus = 0;
    if (_lastSelectionTime != null) {
      final elapsed = now.difference(_lastSelectionTime!).inMilliseconds;
      if (elapsed < 2000) {
        speedBonus = 50;
        _comboCount++;
        _showComboBonus = true;
      } else if (elapsed < 4000) {
        speedBonus = 25;
        _comboCount++;
      } else {
        _comboCount = 0;
      }
    }
    _lastSelectionTime = now;

    // Base points + speed bonus + combo multiplier
    final points = 100 + speedBonus + (_comboCount * 10);

    setState(() {
      _selectedOption = index;
      _showResult = true;
      _myProgress = (_myProgress + 1).clamp(0, 5);
      _waitingForThem = true;
      _vibeScore += points;
    });

    _scorePopController.forward(from: 0);

    // Hide combo bonus after delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showComboBonus = false);
    });

    // Simulate THEM making a selection
    Future.delayed(Duration(milliseconds: 400 + _random.nextInt(800)), () {
      if (!mounted) return;

      setState(() {
        _theirSelectedOption = _random.nextInt(_currentRoundData['options'].length);
        _theirProgress = (_theirProgress + 1).clamp(0, 5);
        _waitingForThem = false;

        // Match bonus!
        if (_selectedOption == _theirSelectedOption) {
          _vibeScore += 200;
          _comboCount += 2;
        }

        _roundHistory.add({
          'mySelection': _selectedOption!,
          'theirSelection': _theirSelectedOption!,
        });
      });

      Future.delayed(const Duration(milliseconds: 700), () {
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
      _vibeScore = 0;
      _comboCount = 0;
      _lastSelectionTime = null;
      _roundHistory.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isGameComplete = _currentRound >= _gameRounds.length;

    return Scaffold(
      backgroundColor: AppTheme.deepPurple,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with score
            _buildTopBar(),

            // Progress bar (smaller now)
            MatchProgressBar(
              myProgress: _myProgress,
              theirProgress: _theirProgress,
              theirBlurLevel: _theirBlurLevel,
            ),

            // Game content (HERO - words first!)
            Expanded(
              child: isGameComplete
                  ? _buildGameComplete()
                  : _buildGameRound(),
            ),

            // Smaller profile image at bottom
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: SizedBox(
                height: 140,
                child: BlurredProfileImage(revealProgress: _myProgress),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Logo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.crystalCyan, AppTheme.crystalPink],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppTheme.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'MatchMake!',
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Vibe Score
          AnimatedBuilder(
            animation: _scorePopAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scorePopAnimation.value,
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.crystalCyan.withValues(alpha: 0.3),
                    AppTheme.crystalPink.withValues(alpha: 0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.crystalCyan.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.bolt,
                    color: AppTheme.crystalGold,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$_vibeScore',
                    style: const TextStyle(
                      color: AppTheme.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameRound() {
    final roundData = _currentRoundData;
    final options = roundData['options'] as List<String>;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Round + Combo indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.midPurple,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppTheme.softPurple,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  'ROUND ${_currentRound + 1}/${_gameRounds.length}',
                  style: const TextStyle(
                    color: AppTheme.crystalCyan,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              if (_comboCount > 0)
                AnimatedOpacity(
                  opacity: _showComboBonus ? 1.0 : 0.7,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.crystalGold, AppTheme.crystalPink],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.crystalGold.withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          color: AppTheme.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_comboCount}x COMBO',
                          style: const TextStyle(
                            color: AppTheme.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Prompt (styled as game challenge)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.midPurple,
                  AppTheme.softPurple.withValues(alpha: 0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.crystalCyan.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.crystalCyan.withValues(alpha: 0.15),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  roundData['prompt'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                if (_waitingForThem) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.crystalPink,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'They\'re choosing...',
                        style: TextStyle(
                          color: AppTheme.crystalPink,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // HERO: Word cloud with frosted glass buttons
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 12,
                runSpacing: 14,
                alignment: WrapAlignment.center,
                children: List.generate(options.length, (index) {
                  return FrostedGlassButton(
                    text: options[index],
                    isSelected: _selectedOption == index,
                    isTheirSelection: _theirSelectedOption == index,
                    colorIndex: index,
                    floatSpeed: 0.8 + (index * 0.15),
                    onPressed: () => _handleOptionSelected(index),
                  );
                }),
              ),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Victory container
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  AppTheme.crystalCyan.withValues(alpha: 0.2),
                  AppTheme.deepPurple,
                ],
                radius: 1.5,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppTheme.crystalCyan.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                // Trophy/Star icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.crystalGold, AppTheme.crystalPink],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.crystalGold.withValues(alpha: 0.5),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: AppTheme.white,
                    size: 48,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  isFullReveal ? 'UNLOCKED!' : 'COMPLETE!',
                  style: TextStyle(
                    color: AppTheme.crystalCyan,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color: AppTheme.crystalCyan.withValues(alpha: 0.6),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatBox('VIBE SCORE', '$_vibeScore', AppTheme.crystalGold),
                    _buildStatBox('MATCHES', '$matchCount/5', AppTheme.crystalPink),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: GameButton(
              text: 'PLAY AGAIN',
              onPressed: _resetGame,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
