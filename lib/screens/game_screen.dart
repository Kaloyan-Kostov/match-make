import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/frosted_glass_button.dart';
import '../widgets/match_progress_bar.dart';
import '../widgets/euphoria_celebration.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  int _currentRound = 0;
  int? _selectedOption;
  int? _theirSelectedOption;
  bool _waitingForThem = false;
  int _vibeScore = 0;
  int _comboCount = 0;
  bool _showCelebration = false;

  late AnimationController _impactController;
  late Animation<double> _impactAnimation;

  final math.Random _random = math.Random();

  final List<Map<String, dynamic>> _gameRounds = [
    {'prompt': 'The perfect first date is...', 'options': ['Adventure', 'Coffee', 'Dinner', 'Movies', 'Stars']},
    {'prompt': 'My ideal weekend involves...', 'options': ['Hiking', 'Netflix', 'Brunch', 'Gaming', 'Reading']},
    {'prompt': 'I value most in a partner...', 'options': ['Humor', 'Ambition', 'Kindness', 'Smarts', 'Loyalty']},
    {'prompt': 'My love language is...', 'options': ['Words', 'Touch', 'Gifts', 'Time', 'Acts']},
    {'prompt': 'In 5 years, I see myself...', 'options': ['Traveling', 'Settled', 'Growing', 'Exploring', 'Creating']},
  ];

  @override
  void initState() {
    super.initState();
    _impactController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _impactAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.1), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 0.95), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 35),
    ]).animate(CurvedAnimation(parent: _impactController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _impactController.dispose();
    super.dispose();
  }

  bool get _isComplete => _currentRound >= 5;
  int get _revealPercent => (_currentRound * 20).clamp(0, 100);

  Map<String, dynamic> get _currentRoundData {
    if (_currentRound >= _gameRounds.length) return _gameRounds.last;
    return _gameRounds[_currentRound];
  }

  void _handleOptionSelected(int index) {
    if (_selectedOption != null || _waitingForThem || _isComplete) return;

    setState(() {
      _selectedOption = index;
      _waitingForThem = true;
      _vibeScore += 100 + (_comboCount * 10);
      _comboCount++;
    });

    Future.delayed(Duration(milliseconds: 300 + _random.nextInt(400)), () {
      if (!mounted) return;
      setState(() {
        _theirSelectedOption = _random.nextInt(5);
        _waitingForThem = false;
        if (_selectedOption == _theirSelectedOption) {
          _vibeScore += 200;
        }
      });

      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        setState(() {
          _currentRound++;
          _selectedOption = null;
          _theirSelectedOption = null;

          if (_isComplete) {
            _showCelebration = true;
            _impactController.forward(from: 0);
          }
        });
      });
    });
  }

  void _resetGame() {
    setState(() {
      _currentRound = 0;
      _selectedOption = null;
      _theirSelectedOption = null;
      _waitingForThem = false;
      _vibeScore = 0;
      _comboCount = 0;
      _showCelebration = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepPurple,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                const SizedBox(height: 8),
                _buildTopBar(),
                const SizedBox(height: 12),

                // RESTORED: Simple progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: MatchProgressBar(
                    myProgress: _currentRound,
                    theirProgress: _currentRound,
                  ),
                ),

                const SizedBox(height: 16),
                _buildPhotoCards(),
                const SizedBox(height: 16),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _isComplete ? _buildComplete() : _buildGameRound(),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),

            // Euphoria celebration
            Positioned.fill(
              child: EuphoriaCelebration(
                trigger: _showCelebration,
                onComplete: () {
                  if (mounted) setState(() => _showCelebration = false);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.crystalCyan, AppTheme.crystalPink],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          const Text(
            'MatchMake!',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.midPurple,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.crystalGold.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt, color: AppTheme.crystalGold, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$_vibeScore',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 150,
        child: AnimatedBuilder(
          animation: _impactAnimation,
          builder: (context, child) {
            final scale = _isComplete ? _impactAnimation.value : 1.0;
            return Transform.scale(scale: scale, child: child);
          },
          child: Row(
            children: [
              Expanded(
                child: Transform.rotate(
                  angle: -5 * math.pi / 180,
                  child: _buildPhotoCard(isMe: true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Transform.rotate(
                  angle: 5 * math.pi / 180,
                  child: _buildPhotoCard(isMe: false),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoCard({required bool isMe}) {
    final color = isMe ? AppTheme.crystalCyan : AppTheme.crystalPink;
    final blurAmount = isMe ? 0.0 : ((5 - _currentRound) * 3.0).clamp(0.0, 15.0);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          if (_isComplete)
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 14,
              spreadRadius: 2,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.2),
                    AppTheme.midPurple,
                    AppTheme.deepPurple,
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: color.withValues(alpha: isMe ? 0.5 : 0.3),
                ),
              ),
            ),

            if (!isMe && blurAmount > 0)
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
                child: Container(color: Colors.transparent),
              ),

            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.deepPurple.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    isMe ? '100%' : '$_revealPercent%',
                    style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            if (!isMe && _currentRound == 0)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.deepPurple.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.lock, color: color, size: 24),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameRound() {
    final data = _currentRoundData;
    final options = data['options'] as List<String>;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.midPurple,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'ROUND ${_currentRound + 1}/5',
                style: const TextStyle(color: AppTheme.crystalCyan, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
            if (_comboCount > 1)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.crystalGold, AppTheme.crystalPink]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.white, size: 12),
                    const SizedBox(width: 3),
                    Text('${_comboCount}x', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.midPurple,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.crystalCyan.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Text(
                data['prompt'],
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (_waitingForThem) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.crystalPink)),
                    const SizedBox(width: 6),
                    const Text('Their turn...', style: TextStyle(color: AppTheme.crystalPink, fontSize: 11)),
                  ],
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 14),

        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: List.generate(options.length, (i) {
                return FrostedGlassButton(
                  text: options[i],
                  isSelected: _selectedOption == i,
                  isTheirSelection: _theirSelectedOption == i,
                  colorIndex: i,
                  floatSpeed: 0.9 + (i * 0.08),
                  onPressed: () => _handleOptionSelected(i),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComplete() {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [AppTheme.crystalCyan.withValues(alpha: 0.15), AppTheme.deepPurple],
              radius: 1.2,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.crystalCyan.withValues(alpha: 0.4), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.crystalGold, AppTheme.crystalPink, AppTheme.crystalCyan]),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                'MATCHED!',
                style: TextStyle(color: AppTheme.crystalCyan, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              const SizedBox(height: 12),
              Text('Vibe Score: $_vibeScore', style: const TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _resetGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.crystalCyan,
                  foregroundColor: AppTheme.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('PLAY AGAIN', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
