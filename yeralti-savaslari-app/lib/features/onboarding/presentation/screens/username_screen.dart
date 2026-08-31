import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/persistence/save_service.dart';
import '../../../mining/application/game_notifier.dart';
import '../../../multiplayer/presentation/screens/main_menu_screen.dart';

class UsernameScreen extends ConsumerStatefulWidget {
  const UsernameScreen({super.key});

  @override
  ConsumerState<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends ConsumerState<UsernameScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _errorMessage;

  final List<String> _randomNames = [
    'TitanyumUsta',
    'AteşKazması',
    'KayaKıran',
    'DerinAvcı',
    'VolkanMuhafız',
    'LavYutan',
    'GökGürültüsü',
    'ObsidyenKral',
    'MadenGözcüsü',
    'KızılYumruk',
  ];

  @override
  void initState() {
    super.initState();
    _pickRandomName();
  }

  void _pickRandomName() {
    final rnd = Random();
    final name = _randomNames[rnd.nextInt(_randomNames.length)];
    _controller.text = name;
    _errorMessage = null;
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _controller.text.trim();

    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Lütfen bir madenci adı girin.';
      });
      return;
    }

    if (name.length < 3) {
      setState(() {
        _errorMessage = 'İsim en az 3 karakter olmalıdır.';
      });
      return;
    }

    if (name.length > 16) {
      setState(() {
        _errorMessage = 'İsim en fazla 16 karakter olabilir.';
      });
      return;
    }

    // 1. Riverpod state güncelle
    ref.read(gameNotifierProvider.notifier).setPlayerName(name);

    // 2. Kalıcı kaydet
    final updatedPlayer = ref.read(gameNotifierProvider).player.copyWith(playerName: name);
    await SaveService.savePlayer(updatedPlayer);

    // 3. Onboarding tamamlandı olarak işaretle
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);

    if (!mounted) return;

    // 4. Ana Menüye geç
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => const MainMenuScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Arka Plan
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.2),
                  radius: 1.4,
                  colors: [
                    Color(0xFF261324),
                    Color(0xFF140D1A),
                    Color(0xFF08060B),
                  ],
                ),
              ),
            ),

            // Ana Kart
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 580),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    color: AppColors.hudPanel.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.lavaOrange.withValues(alpha: 0.6), width: 1.8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.lavaOrange.withValues(alpha: 0.25),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.8),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Başlık İkonu / Logo
                      Container(
                        height: 64,
                        width: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF100A15),
                          border: Border.all(color: AppColors.lavaOrange, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.lavaOrange.withValues(alpha: 0.5),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_pin_rounded,
                          color: AppColors.lavaOrange,
                          size: 38,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Başlık
                      const Text(
                        'MADENCİ KİMLİĞİNİ OLUŞTUR',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),

                      const Text(
                        'Yeraltı Savaşları dünyasında diğer madenciler seni bu isimle tanıyacak.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11.5,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // İsim Giriş Alanı & Rastgele İsim Butonu
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              maxLength: 16,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Madenci adını yaz...',
                                hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                                errorText: _errorMessage,
                                counterStyle: const TextStyle(color: Colors.white38, fontSize: 10),
                                prefixIcon: const Icon(Icons.badge, color: AppColors.goldText, size: 20),
                                filled: true,
                                fillColor: const Color(0xFF0F0B17),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF4A2518), width: 1.2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.lavaOrange, width: 1.8),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.resetRed, width: 1.2),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.resetRed, width: 1.8),
                                ),
                              ),
                              onChanged: (_) {
                                if (_errorMessage != null) {
                                  setState(() {
                                    _errorMessage = null;
                                  });
                                }
                              },
                              onSubmitted: (_) => _submit(),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Rastgele İsim Üretme Zarı
                          Tooltip(
                            message: 'Rastgele İsim Seç',
                            child: InkWell(
                              onTap: _pickRandomName,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                height: 48,
                                width: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1D1426),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.cyanText.withValues(alpha: 0.7), width: 1.2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.cyanText.withValues(alpha: 0.2),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.casino_rounded,
                                  color: AppColors.cyanText,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Oyuna Başla Butonu
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.lavaOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 8,
                            shadowColor: AppColors.lavaOrange.withValues(alpha: 0.6),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_arrow_rounded, size: 22),
                              SizedBox(width: 8),
                              Text(
                                'OYUNA BAŞLA',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
