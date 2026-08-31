import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'username_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<_OnboardingItem> _items = const [
    _OnboardingItem(
      icon: Icons.landscape_rounded,
      badgeText: 'DERİN KAZI & KEŞİF',
      title: 'Yeraltına İn & Keşfet',
      description:
          '500 Bölümlük volkanik derinlik haritasında kazı yap. Gizli madenleri, elmasları ve antik hazineleri gün yüzüne çıkar!',
      accentColor: AppColors.lavaOrange,
      gradientColors: [Color(0xFFFF5722), Color(0xFFFF9100)],
    ),
    _OnboardingItem(
      icon: Icons.shield_rounded,
      badgeText: 'AKSİYON & SAVUNMA',
      title: 'Savaş & Hayatta Kal',
      description:
          'Derinliklerdeki boss canavarlara karşı silahlarını kuşan. Canını ve enerjini yöneterek en derine ilk sen ulaş!',
      accentColor: AppColors.lavaFlame,
      gradientColors: [Color(0xFFFF3D00), Color(0xFFFF1744)],
    ),
    _OnboardingItem(
      icon: Icons.groups_rounded,
      badgeText: 'MADENCİ EKİBİ',
      title: 'Ekip Kur, Birlikte Kaz',
      description:
          '1-10 kişilik madenci ekibiyle güçlerini birleştir. Takım arkadaşlarınla yardımlaşarak maden bonuslarını katla!',
      accentColor: AppColors.cyanText,
      gradientColors: [Color(0xFF00E5FF), Color(0xFF00B0FF)],
    ),
    _OnboardingItem(
      icon: Icons.emoji_events_rounded,
      badgeText: 'ÖDÜLLER & ATÖLYE',
      title: 'Görevler & Güçlendirmeler',
      description:
          'Haftalık görevleri tamamla, altın ve elmas kazan. Atölyede kazmalarını güçlendir, efsanevi zırhlarını kuşan!',
      accentColor: AppColors.goldText,
      gradientColors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
    ),
  ];

  void _onNext() {
    if (_currentIndex < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToUsername();
    }
  }

  void _onBack() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToUsername() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => const UsernameScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Arka Plan Gradient
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.2),
                  radius: 1.4,
                  colors: [
                    Color(0xFF221525),
                    Color(0xFF140D1A),
                    Color(0xFF0A070E),
                  ],
                ),
              ),
            ),

            // Üst Bar: Atla Butonu
            Positioned(
              top: 10,
              right: 16,
              child: TextButton(
                onPressed: _navigateToUsername,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white60,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Atla',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded, color: Colors.white70, size: 18),
                  ],
                ),
              ),
            ),

            // Ana İçerik Sayfaları
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 720, maxHeight: 390),
                margin: const EdgeInsets.fromLTRB(16, 40, 16, 10),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _items.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return isLandscape
                        ? _buildLandscapeContent(item)
                        : _buildPortraitContent(item);
                  },
                ),
              ),
            ),

            // Alt Kontrol Barı: Noktalar & İleri / Geri Butonları
            Positioned(
              bottom: 12,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Geri Butonu
                  _currentIndex > 0
                      ? TextButton.icon(
                          onPressed: _onBack,
                          icon: const Icon(Icons.arrow_back_rounded, size: 16, color: Colors.white70),
                          label: const Text(
                            'Geri',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        )
                      : const SizedBox(width: 70),

                  // Sayfa Nokta Göstergeleri (Dots Indicator)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(_items.length, (idx) {
                      final isSelected = idx == _currentIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isSelected ? 22 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _items[_currentIndex].accentColor
                              : Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: _items[_currentIndex].accentColor.withValues(alpha: 0.6),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                      );
                    }),
                  ),

                  // İleri / Başla Butonu
                  ElevatedButton(
                    onPressed: _onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _items[_currentIndex].accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 6,
                      shadowColor: _items[_currentIndex].accentColor.withValues(alpha: 0.6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentIndex == _items.length - 1 ? 'DEVAM ET' : 'İLERİ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLandscapeContent(_OnboardingItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.hudPanel.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: item.accentColor.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: item.accentColor.withValues(alpha: 0.15),
            blurRadius: 24,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Sol: İkon Kartı
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: item.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: item.accentColor.withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(item.icon, size: 64, color: Colors.white),
          ),
          const SizedBox(width: 24),

          // Sağ: Başlık, Rozet ve Açıklama
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rozet
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: item.accentColor.withValues(alpha: 0.8)),
                  ),
                  child: Text(
                    item.badgeText,
                    style: TextStyle(
                      color: item.accentColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Başlık
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 8),

                // Açıklama
                Text(
                  item.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortraitContent(_OnboardingItem item) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.hudPanel.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: item.accentColor.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: item.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(item.icon, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingItem {
  final IconData icon;
  final String badgeText;
  final String title;
  final String description;
  final Color accentColor;
  final List<Color> gradientColors;

  const _OnboardingItem({
    required this.icon,
    required this.badgeText,
    required this.title,
    required this.description,
    required this.accentColor,
    required this.gradientColors,
  });
}
