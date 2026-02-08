import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/match_progress_bar.dart';
import '../widgets/dual_photo_display.dart';
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
  bool _isMyTurn = true;

  // Game scoring
  int _vibeScore = 0;
  int _comboCount = 0;
  DateTime? _lastSelectionTime;

  final Random _random = Random();

  late AnimationController _scorePopController;
  late Animation<double> _scorePopAnimation;

  final List<Map<String, dynamic>> _gameRounds = [
    {'prompt': 'The perfect first date is...', 'options': ['Adventure', 'Coffee', 'Dinner', 'Movies', 'Stargazing']},
    {'prompt': 'My ideal weekend involves...', 'options': ['Hiking', 'Netflix', 'Brunch', 'Gaming', 'Reading']},
    {'prompt': 'I value most in a partner...', 'options': ['Humor', 'Ambition', 'Kindness', 'Smarts', 'Loyalty']},
    {'prompt': 'My love language is...', 'options': ['Words', 'Touch', 'Gifts', 'Time', 'Acts']},
    {'prompt': 'In 5 years, I see myself...', 'options': ['Traveling', 'Settled', 'Growing', 'Exploring', 'Creating']},
  ];

  final List<Map<String, int>> _roundHistory = [];

  @override
  void initState() {
    super.initState();
    _scorePopController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scorePopAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _scorePopController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _scorePopController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _currentRoundData {
    if (_currentRound >= _gameRounds.length) return _gameRounds.last;
    return _gameRounds[_currentRound];
  }

  void _handleOptionSelected(int index) {
    if (_showResult || _waitingForThem) return;

    final now = DateTime.now();
    int speedBonus = 0;
    if (_lastSelectionTime != null) {
      final elapsed = now.difference(_lastSelectionTime!).inMilliseconds;
      if (elapsed < 2000) {
        speedBonus = 50;
        _comboCount++;
      } else if (elapsed < 4000) {
        speedBonus = 25;
        _comboCount++;
      } else {
        _comboCount = 0;
      }
    }
    _lastSelectionTime = now;

    final points = 100 + speedBonus + (_comboCount * 10);

    setState(() {
      _selectedOption = index;
      _showResult = true;
      _myProgress = (_myProgress + 1).clamp(0, 5);
      _waitingForThem = true;
      _isMyTurn = false;
      _vibeScore += points;
    });

    _scorePopController.forward(from: 0);

    // Simulate THEM
    Future.delayed(Duration(milliseconds: 400 + _random.nextInt(600)), () {
      if (!mounted) return;

      setState(() {
        _theirSelectedOption = _random.nextInt(_currentRoundData['options'].length);
        _theirProgress = (_theirProgress + 1).clamp(0, 5);
        _waitingForThem = false;

        if (_selectedOption == _theirSelectedOption) {
          _vibeScore += 200;
          _comboCount += 2;
        }

        _roundHistory.add({
          'mySelection': _selectedOption!,
          'theirSelection': _theirSelectedOption!,
        });
      });

      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() {
          _currentRound++;
          _selectedOption = null;
          _theirSelectedOption = null;
          _showResult = false;
          _isMyTurn = true;
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
      _isMyTurn = true;
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            final isCompact = screenHeight < 650;

            return Column(
              children: [
                // Top bar
                _buildTopBar(),

                // Progress bar (includes avatars)
                MatchProgressBar(
                  myProgress: _myProgress,
                  theirProgress: _theirProgress,
                ),

                const SizedBox(height: 8),

                // Dual photos
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: isCompact ? 120 : 150,
                    child: DualPhotoDisplay(
                      revealProgress: _myProgress,
                      isMyTurn: _isMyTurn,
                    ),
                  ),
                ),

                SizedBox(height: isCompact ? 8 : 12),

                // Game content
                Expanded(
                  child: isGameComplete
                      ? _buildGameComplete()
                      : _buildGameRound(isCompact),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.crystalCyan, AppTheme.crystalPink],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_awesome, color: AppTheme.white, size: 16),
          ),
          const SizedBox(width: 8),
          const Text(
            'MatchMake!',
            style: TextStyle(color: AppTheme.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const Spacer(),

          // Vibe Score
          ScaleTransition(
            scale: _scorePopAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.midPurple,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.crystalGold.withValues(alpha: 0.5), width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt, color: AppTheme.crystalGold, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '$_vibeScore',
                    style: const TextStyle(color: AppTheme.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameRound(bool isCompact) {
    final roundData = _currentRoundData;
    final options = roundData['options'] as List<String>;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Round + Combo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.midPurple,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'ROUND ${_currentRound + 1}/5',
                  style: const TextStyle(
                    color: AppTheme.crystalCyan,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              if (_comboCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppTheme.crystalGold, AppTheme.crystalPink]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department, color: AppTheme.white, size: 12),
                      const SizedBox(width: 3),
                      Text('${_comboCount}x', style: const TextStyle(color: AppTheme.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),

          SizedBox(height: isCompact ? 8 : 12),

          // Prompt
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isCompact ? 12 : 14),
            decoration: BoxDecoration(
              color: AppTheme.midPurple,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.crystalCyan.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Column(
              children: [
                Text(
                  roundData['prompt'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: isCompact ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_waitingForThem) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.crystalPink),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Their turn...',
                        style: TextStyle(color: AppTheme.crystalPink, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: isCompact ? 10 : 14),

          // Word buttons
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: List.generate(options.length, (index) {
                  return FrostedGlassButton(
                    text: options[index],
                    isSelected: _selectedOption == index,
                    isTheirSelection: _theirSelectedOption == index,
                    colorIndex: index,
                    floatSpeed: 0.9 + (index * 0.1),
                    onPressed: () => _handleOptionSelected(index),
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildGameComplete() {
    final matchCount = _roundHistory.where((r) => r['mySelection'] == r['theirSelection']).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [AppTheme.crystalCyan.withValues(alpha: 0.15), AppTheme.deepPurple],
                radius: 1.5,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.crystalCyan.withValues(alpha: 0.4), width: 2),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppTheme.crystalGold, AppTheme.crystalPink]),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome, color: AppTheme.white, size: 36),
                ),
                const SizedBox(height: 14),
                const Text(
                  'COMPLETE!',
                  style: TextStyle(color: AppTheme.crystalCyan, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStat('VIBE', '$_vibeScore', AppTheme.crystalGold),
                    _buildStat('MATCH', '$matchCount/5', AppTheme.crystalPink),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: GameButton(text: 'PLAY AGAIN', onPressed: _resetGame),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
