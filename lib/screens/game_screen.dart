import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/frosted_glass_button.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // Game state
  int _currentRound = 0;
  int? _selectedOption;
  int? _theirSelectedOption;
  bool _waitingForThem = false;
  int _vibeScore = 0;
  int _comboCount = 0;

  final math.Random _random = math.Random();

  // Animation controller for the central logo
  late AnimationController _logoController;
  late Animation<double> _logoAnimation;

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
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _logoAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  // Progress values (0.0 to 1.0)
  double get _myProgress => _currentRound / 5.0;
  double get _theirProgress => _currentRound / 5.0;
  bool get _isComplete => _currentRound >= 5;
  int get _revealPercent => (_currentRound * 20).clamp(0, 100);

  Map<String, dynamic> get _currentRoundData {
    if (_currentRound >= _gameRounds.length) return _gameRounds.last;
    return _gameRounds[_currentRound];
  }

  void _handleOptionSelected(int index) {
    if (_selectedOption != null || _waitingForThem) return;

    setState(() {
      _selectedOption = index;
      _waitingForThem = true;
      _vibeScore += 100 + (_comboCount * 10);
      _comboCount++;
    });

    // Simulate THEM selecting
    Future.delayed(Duration(milliseconds: 300 + _random.nextInt(500)), () {
      if (!mounted) return;
      setState(() {
        _theirSelectedOption = _random.nextInt(5);
        _waitingForThem = false;
        if (_selectedOption == _theirSelectedOption) {
          _vibeScore += 200;
        }
      });

      // Move to next round
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        setState(() {
          _currentRound++;
          _selectedOption = null;
          _theirSelectedOption = null;
          if (_isComplete) {
            _logoController.repeat(reverse: true);
          }
        });
      });
    });
  }

  void _resetGame() {
    _logoController.stop();
    _logoController.reset();
    setState(() {
      _currentRound = 0;
      _selectedOption = null;
      _theirSelectedOption = null;
      _waitingForThem = false;
      _vibeScore = 0;
      _comboCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepPurple,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // 1. TOP BAR
                        _buildTopBar(),
                        const SizedBox(height: 12),

                        // 2. SINGLE PROGRESS BAR
                        _buildProgressBar(),
                        const SizedBox(height: 16),

                        // 3. TWO PHOTO CARDS
                        SizedBox(
                          height: 160,
                          child: _buildPhotoCards(),
                        ),
                        const SizedBox(height: 16),

                        // 4. GAME CONTENT
                        Expanded(
                          child: _isComplete ? _buildComplete() : _buildGameRound(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ==================== TOP BAR ====================
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          // Logo
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
          // Score
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

  // ==================== SINGLE PROGRESS BAR ====================
  Widget _buildProgressBar() {
    return SizedBox(
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Progress track
          Positioned(
            left: 50,
            right: 50,
            child: Container(
              height: 14,
              decoration: BoxDecoration(
                color: AppTheme.deepPurple,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: AppTheme.softPurple, width: 1.5),
              ),
              child: Stack(
                children: [
                  // MY progress (left side)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: (_myProgress * 0.5).clamp(0.0, 0.5),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppTheme.crystalCyan,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                  // THEIR progress (right side)
                  Align(
                    alignment: Alignment.centerRight,
                    child: FractionallySizedBox(
                      widthFactor: (_theirProgress * 0.5).clamp(0.0, 0.5),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppTheme.crystalPink,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // YOU avatar (left)
          Positioned(
            left: 0,
            child: _buildAvatar(label: 'YOU', color: AppTheme.crystalCyan),
          ),

          // THEM avatar (right)
          Positioned(
            right: 0,
            child: _buildAvatar(label: 'THEM', color: AppTheme.crystalPink),
          ),

          // Central star logo
          ScaleTransition(
            scale: _logoAnimation,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _isComplete
                      ? [const Color(0xFFFF5252), const Color(0xFFFF1744)]
                      : [AppTheme.crystalCyan, AppTheme.crystalPink],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_isComplete ? const Color(0xFFFF5252) : AppTheme.crystalCyan)
                        .withValues(alpha: 0.5),
                    blurRadius: 12,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar({required String label, required Color color}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.midPurple,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(Icons.person, color: color, size: 20),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ==================== TWO PHOTO CARDS ====================
  Widget _buildPhotoCards() {
    return Row(
      children: [
        // ME photo (left, tilted -5°)
        Expanded(
          child: Transform.rotate(
            angle: -5 * math.pi / 180,
            child: _buildPhotoCard(isMe: true),
          ),
        ),
        const SizedBox(width: 16),
        // THEM photo (right, tilted +5°)
        Expanded(
          child: Transform.rotate(
            angle: 5 * math.pi / 180,
            child: _buildPhotoCard(isMe: false),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoCard({required bool isMe}) {
    final color = isMe ? AppTheme.crystalCyan : AppTheme.crystalPink;
    final blurAmount = isMe ? 0.0 : (5 - _currentRound) * 3.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo background
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

            // Blur for THEM only
            if (!isMe && blurAmount > 0)
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
                child: Container(color: Colors.transparent),
              ),

            // Label
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.deepPurple.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isMe ? '100%' : '$_revealPercent%',
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // Lock icon when 0%
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

  // ==================== GAME ROUND ====================
  Widget _buildGameRound() {
    final data = _currentRoundData;
    final options = data['options'] as List<String>;

    return Column(
      children: [
        // Round indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.midPurple,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'ROUND ${_currentRound + 1}/5',
                style: const TextStyle(
                  color: AppTheme.crystalCyan,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (_comboCount > 1)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.crystalGold, AppTheme.crystalPink],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.white, size: 12),
                    const SizedBox(width: 3),
                    Text(
                      '${_comboCount}x',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Prompt
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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_waitingForThem) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.crystalPink,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Their turn...',
                      style: TextStyle(color: AppTheme.crystalPink, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Word buttons
        Expanded(
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
                floatSpeed: 0.9 + (i * 0.1),
                onPressed: () => _handleOptionSelected(i),
              );
            }),
          ),
        ),
      ],
    );
  }

  // ==================== COMPLETE SCREEN ====================
  Widget _buildComplete() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.midPurple,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.crystalCyan.withValues(alpha: 0.4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.crystalGold, AppTheme.crystalPink],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'COMPLETE!',
              style: TextStyle(
                color: AppTheme.crystalCyan,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Vibe Score: $_vibeScore',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
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
    );
  }
}
