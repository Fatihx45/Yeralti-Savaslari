import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../mining/application/game_notifier.dart';
import '../../../multiplayer/presentation/screens/main_menu_screen.dart';
import '../../../onboarding/presentation/screens/onboarding_screen.dart';
import '../widgets/lava_particles_painter.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  double _loadingProgress = 0.0;
  Timer? _progressTimer;
  Timer? _tipTimer;
  int _currentTipIndex = 0;
  final List<LavaParticle> _particles = [];
  final Random _rnd = Random();

  final List<String> _loadingTipsTr = [
    '🌋 1-500 Bölüm volkanik derinlik haritaları inşa ediliyor...',
    '⛏️ Titanyum kazmalar, dinamitler ve silahlar kuşanılıyor...',
    '👥 Çok oyunculu lobi odaları ve arkadaş ağı senkronize ediliyor...',
    '👑 500. Bölüm Titan\'ın Kalbi ve Boss zindanı mühürleniyor...',
  ];

  final List<String> _loadingTipsEn = [
    '🌋 Constructing Stage 1-500 volcanic depth maps...',
    '⛏️ Equipping titanium pickaxes, dynamites & weapons...',
    '👥 Synchronizing multiplayer lobby rooms & friends network...',
    '👑 Sealing Stage 500 Heart of Titan Boss dungeon...',
  ];

  @override
  void initState() {
    super.initState();

    // 1. Parçacık Animasyonu (Sonsuz Döngü)
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // 2. Nefes Alan Magma Logo Animasyonu
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    // 3. Parçacıkları Başlat
    for (int i = 0; i < 45; i++) {
      _particles.add(LavaParticle.random(_rnd, const Size(800, 600)));
    }

    // 4. İpucu Değiştirme Zamanlayıcısı
    _tipTimer = Timer.periodic(const Duration(milliseconds: 1100), (_) {
      if (mounted) {
        setState(() {
          _currentTipIndex = (_currentTipIndex + 1) % _loadingTipsTr.length;
        });
      }
    });

    // 5. Yükleme Barı İlerlemesi (0.0 -> 1.0)
    _startProgress();
  }

  void _startProgress() {
    const totalSteps = 100;
    const intervalMs = 28; // ~2.8 saniyede açılış tamamlanır

    _progressTimer = Timer.periodic(const Duration(milliseconds: intervalMs), (timer) {
      if (!mounted) return;

      setState(() {
        _loadingProgress += 1.0 / totalSteps;
        if (_loadingProgress >= 1.0) {
          _loadingProgress = 1.0;
          _progressTimer?.cancel();
          _navigateToNextScreen();
        }
      });
    });
  }

  void _navigateToNextScreen() {
    Future.delayed(const Duration(milliseconds: 250), () async {
      if (!mounted) return;

      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

      if (!mounted) return;

      final Widget targetScreen = hasSeenOnboarding
          ? const MainMenuScreen()
          : const OnboardingScreen();

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _particleController.dispose();
    _pulseController.dispose();
    _progressTimer?.cancel();
    _tipTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(gameNotifierProvider.select((s) => s.player.languageCode));
    final isEn = lang == 'en';
    final tips = isEn ? _loadingTipsEn : _loadingTipsTr;
    final currentTip = tips[_currentTipIndex % tips.length];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // KATMAN 1: VOLKANİK ARKA PLAN GRADIENT
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.1),
                radius: 1.4,
                colors: [
                  Color(0xFF2A1525), // Merkez kor tonu
                  Color(0xFF140D1A), // Orta obsidyen
                  Color(0xFF07050A), // Dış derin zemin
                ],
              ),
            ),
          ),

          // KATMAN 2: CANLI LAV KIVILCIMI PARÇACIK MOTORU
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: LavaParticlesPainter(
                  animationValue: _particleController.value,
                  particles: _particles,
                ),
              );
            },
          ),

          // KATMAN 3: MERKEZİ LOGO, TİPOGRAFİ VE YÜKLEME BİLEŞENLERİ
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🌋 NEFES ALAN MAGMA LOGO ARMASI
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          height: 165,
                          width: 185,
                          decoration: BoxDecoration(
                            color: const Color(0xFF100A15),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFFF6D00), width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF3D00).withValues(alpha: 0.65),
                                blurRadius: 36,
                                spreadRadius: 4,
                              ),
                              BoxShadow(
                                color: const Color(0xFFFFD600).withValues(alpha: 0.4),
                                blurRadius: 16,
                                spreadRadius: 1,
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.9),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Image.asset(
                              'assets/image/logo.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),

                  // ⚔️ PARILDAYAN VOLKANİK BAŞLIK & TİPOGRAFİ
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFFFD54F), Color(0xFFFF5722), Color(0xFFFFAB00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      isEn ? 'UNDERGROUND WARS' : 'YERALTI SAVAŞLARI',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEn
                        ? 'Deep Mining • 500 Stages & Battle Royale'
                        : 'Derin Kazı • 500 Bölüm Hikaye & Battle Royale',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ⚡ AKKOR LAV ENERJİ YÜKLEME ÇUBUĞU
                  Container(
                    width: 320,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E0812),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF4A2518), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.lavaOrange.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // İlerleme Dolgusu (Gradient & Glow)
                        FractionallySizedBox(
                          widthFactor: _loadingProgress.clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFFF3D00),
                                  Color(0xFFFF9100),
                                  Color(0xFFFFD600),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF9100).withValues(alpha: 0.8),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Yüzde Göstergesi & İpucu Metni
                  Text(
                    '%${(_loadingProgress * 100).toInt()}',
                    style: const TextStyle(
                      color: AppColors.goldText,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      currentTip,
                      key: ValueKey<String>(currentTip),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
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
}
