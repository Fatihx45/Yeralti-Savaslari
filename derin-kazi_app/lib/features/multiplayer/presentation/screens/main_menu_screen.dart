import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../mining/application/game_notifier.dart';
import '../../../mining/domain/models/stage_config_model.dart';
import '../../../mining/presentation/screens/stage_select_screen.dart';
import '../../../mining/presentation/screens/weapon_shop_screen.dart';
import '../../../mining/presentation/screens/forge_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../application/lobby_notifier.dart';
import '../../../cosmetics/presentation/screens/cosmetics_screen.dart';
import '../../../quests/presentation/widgets/quest_dialog.dart';
import '../../../ai_team/presentation/screens/team_lobby_screen.dart';
import '../../../friends/presentation/screens/friends_screen.dart';

class MainMenuScreen extends ConsumerStatefulWidget {
  const MainMenuScreen({super.key});

  @override
  ConsumerState<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends ConsumerState<MainMenuScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final playerName = ref.read(gameNotifierProvider).player.playerName;
      _nameController.text = playerName;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF140D1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.lavaOrange, width: 2),
        ),
        title: const Row(
          children: [
            Text('🔒', style: TextStyle(fontSize: 26)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'ÇOK OYUNCULU & ARKADAŞLAR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.lavaOrange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.lavaOrange),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.hourglass_top_rounded, color: AppColors.lavaOrange, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'YAKIN GELECEKTE (v1.1 GÜNCELLEMESİ)',
                    style: TextStyle(color: AppColors.lavaOrange, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Gerçek zamanlı PvP Battle Royale, canlı 2-10 madenci düelloları ve oda kurup arkadaş çağırma sistemi v1.1 büyük güncellemesinde aktif edilecektir.',
              style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lavaOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ANLADIM ✅', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameNotifierProvider);
    final int unlockedStage = gameState.player.unlockedStage;
    final stageConfig = StageConfigService.getConfig(unlockedStage);

    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // 1. VOLKANİK OBSİDYEN ARKA PLAN GRADIENT & DERİNLİK
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0, -0.2),
                      radius: 1.3,
                      colors: [
                        Color(0xFF221520), // Merkezde hafif kor yansıması
                        Color(0xFF140D1A), // Orta obsidyen tonu
                        Color(0xFF0A070E), // Dış karanlık volkanik zemin
                      ],
                    ),
                  ),
                ),

                // 2. ANA PANEL (Bazalt Taşı & Kor Ateşi Çerçeveli)
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 830, maxHeight: 420),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.hudPanel.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF4A2518), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.lavaOrange.withValues(alpha: 0.2),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.8),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: isLandscape
                        ? _buildLandscapeLayout(unlockedStage, stageConfig.biomeName, gameState)
                        : _buildPortraitLayout(unlockedStage, stageConfig.biomeName, gameState),
                  ),
                ),

                // Sol Üst: PROFİL Butonu
                Positioned(
                  top: 10,
                  left: 12,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (ctx) => const ProfileScreen()));
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.panelBox,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.lavaOrange.withValues(alpha: 0.6)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.account_circle, color: AppColors.goldText, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            gameState.player.playerName,
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Sağ Üst: ALTIN / ELMAS BAKİYE ROZETİ & AYARLAR Butonu
                Positioned(
                  top: 10,
                  right: 12,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Altın ve Elmas Bakiyesi
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.panelBox,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF4A2518), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Altın
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 11,
                                  height: 11,
                                  decoration: const BoxDecoration(
                                    color: AppColors.goldText,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '${gameState.player.gold}',
                                  style: const TextStyle(
                                    color: AppColors.goldText,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 10),
                            // Elmas
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.diamond, color: AppColors.cyanText, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '${gameState.player.gems}',
                                  style: const TextStyle(
                                    color: AppColors.cyanText,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),

                      // Ayarlar Butonu
                      IconButton(
                        icon: const Icon(Icons.settings, color: AppColors.goldText, size: 24),
                        tooltip: 'Ayarlar',
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (ctx) => const SettingsScreen()));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Yatay Düzen (Landscape - Ana Düzen)
  Widget _buildLandscapeLayout(int unlockedStage, String biomeName, GameState gameState) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Sol Kolon: Resmi Oyun Logosu & Profil Kartı
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🌋 RESMİ OYUN LOGOSU (Kare Volkanik Arma & Akkor Kor Ateşi)
                Center(
                  child: Container(
                    height: 150,
                    width: 170,
                    decoration: BoxDecoration(
                      color: const Color(0xFF100A15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFF6D00), width: 2.0),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF3D00).withValues(alpha: 0.5),
                          blurRadius: 28,
                          spreadRadius: 3,
                        ),
                        BoxShadow(
                          color: const Color(0xFFFFAB00).withValues(alpha: 0.3),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.85),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        'assets/image/logo.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Madenci Kimlik Kartı
                InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (ctx) => const ProfileScreen()));
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.panelBox,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF4A2518), width: 1.2),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFF140D1A),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.lavaOrange, width: 1.5),
                          ),
                          child: const Center(
                            child: Icon(Icons.person, color: AppColors.goldText, size: 16),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                gameState.player.playerName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '🔥 Bölüm $unlockedStage • $biomeName',
                                style: const TextStyle(
                                  color: AppColors.goldText,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 11, color: Colors.white38),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Kostümler & Sosyal Butonları
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFE040FB),
                          side: const BorderSide(color: Color(0xFFE040FB), width: 1.2),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.palette, size: 16),
                        label: const Text('KOSTÜMLER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (ctx) => const CosmeticsScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1D2838),
                          foregroundColor: AppColors.cyanText,
                          side: const BorderSide(color: AppColors.cyanText, width: 1.2),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.people, size: 16, color: AppColors.cyanText),
                        label: const Text('ARKADAŞLAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (ctx) => const FriendsScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // İki Kolon Arası Dikey Kor Çizgi
        Container(
          width: 1.2,
          height: double.infinity,
          color: const Color(0xFF4A2518),
          margin: const EdgeInsets.symmetric(horizontal: 4),
        ),

        // Sağ Kolon: 6 Oyun Modu Butonları (Kaydırılabilir & Taşmasız)
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 1. OYUNA BAŞLA (BÖLÜM SEÇİMİ)
                  _buildMenuButton(
                    title: '🎮 OYUNA BAŞLA',
                    subtitle: 'Kaldığın Yer: Bölüm $unlockedStage • $biomeName',
                    icon: Icons.play_arrow_rounded,
                    buttonColor: const Color(0xFF4E1609),
                    borderColor: AppColors.lavaOrange,
                    textColor: AppColors.lavaOrange,
                    isPrimary: true,
                    onTap: () {
                      ref.read(lobbyNotifierProvider.notifier).setPlayerName(_nameController.text);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (ctx) => const StageSelectScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 5),

                  // 2. EKİP KAZISI (1-10 KİŞİ AI TAKIMI)
                  _buildMenuButton(
                    title: '👥 EKİP KAZISI (1-10 KİŞİ)',
                    subtitle: 'Sistem Madenci Botlarıyla Ortak Kazı & Bonus',
                    icon: Icons.groups,
                    buttonColor: const Color(0xFF0F2C3A),
                    borderColor: AppColors.cyanText,
                    textColor: AppColors.cyanText,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (ctx) => const TeamLobbyScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 5),

                  // 3. 🔒 ÇOK OYUNCULU & ARKADAŞLAR (YAKIN GELECEKTE) - PASİF/BİLGİLENDİRİCİ
                  _buildMenuButton(
                    title: '🔒 ÇOK OYUNCULU (YAKIN GELECEKTE)',
                    subtitle: 'v1.1 Büyük Güncellemesi • 2-10 Battle Royale PvP',
                    icon: Icons.lock_clock,
                    buttonColor: const Color(0xFF1E1A24),
                    borderColor: const Color(0xFF5A4838),
                    textColor: AppColors.goldText.withValues(alpha: 0.7),
                    isLocked: true,
                    onTap: () => _showComingSoonDialog(context),
                  ),
                  const SizedBox(height: 5),

                  // 4. GÖREVLER & ÖDÜLLER
                  _buildMenuButton(
                    title: '📋 GÖREVLER & ÖDÜLLER',
                    subtitle: 'Haftalık Görevler • Elmas & Altın Kazan',
                    icon: Icons.assignment_turned_in,
                    buttonColor: const Color(0xFF3D2608),
                    borderColor: AppColors.goldText,
                    textColor: AppColors.goldText,
                    onTap: () => QuestDialog.showQuestDialog(context),
                  ),
                  const SizedBox(height: 5),

                  // 5. SİLAH VE MERMİ MAĞAZASI
                  _buildMenuButton(
                    title: '🛒 SİLAH & MERMİ MAĞAZASI',
                    subtitle: 'Tabanca, Tüfek, Pompalı & Cephane Al',
                    icon: Icons.shopping_bag,
                    buttonColor: const Color(0xFF361210),
                    borderColor: const Color(0xFFFF7043),
                    textColor: const Color(0xFFFF7043),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (ctx) => const WeaponShopScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 5),

                  // 6. ATÖLYE VE GÜÇLENDİRME
                  _buildMenuButton(
                    title: '⚡ ATÖLYE & GÜÇLENDİRME',
                    subtitle: 'Kazma, Çekiç & Maden Güçlendirmeleri',
                    icon: Icons.hardware,
                    buttonColor: const Color(0xFF2B1038),
                    borderColor: const Color(0xFFE040FB),
                    textColor: const Color(0xFFE040FB),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (ctx) => const ForgeScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Dikey (Fallback) Düzen
  Widget _buildPortraitLayout(int unlockedStage, String biomeName, GameState gameState) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🌋 RESMİ OYUN LOGOSU (Kare Volkanik Arma & Akkor Kor Ateşi)
          Center(
            child: Container(
              height: 155,
              width: 175,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF100A15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFF6D00), width: 2.0),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF3D00).withValues(alpha: 0.5),
                    blurRadius: 28,
                    spreadRadius: 3,
                  ),
                  BoxShadow(
                    color: const Color(0xFFFFAB00).withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.85),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  'assets/image/logo.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // 1. OYUNA BAŞLA (BÖLÜM SEÇİMİ)
          _buildMenuButton(
            title: '🎮 OYUNA BAŞLA',
            subtitle: 'Kaldığın Yer: Bölüm $unlockedStage • $biomeName',
            icon: Icons.play_arrow_rounded,
            buttonColor: const Color(0xFF4E1609),
            borderColor: AppColors.lavaOrange,
            textColor: AppColors.lavaOrange,
            isPrimary: true,
            onTap: () {
              ref.read(lobbyNotifierProvider.notifier).setPlayerName(_nameController.text);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => const StageSelectScreen()),
              );
            },
          ),
          const SizedBox(height: 6),

          // 2. EKİP KAZISI (1-10 KİŞİ AI TAKIMI)
          _buildMenuButton(
            title: '👥 EKİP KAZISI (1-10 KİŞİ)',
            subtitle: 'Sistem Madenci Botlarıyla Ortak Kazı & Bonus',
            icon: Icons.groups,
            buttonColor: const Color(0xFF0F2C3A),
            borderColor: AppColors.cyanText,
            textColor: AppColors.cyanText,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => const TeamLobbyScreen()),
              );
            },
          ),
          const SizedBox(height: 6),

          // 3. 🔒 ÇOK OYUNCULU & ARKADAŞLAR (YAKIN GELECEKTE)
          _buildMenuButton(
            title: '🔒 ÇOK OYUNCULU (YAKIN GELECEKTE)',
            subtitle: 'v1.1 Büyük Güncellemesi • 2-10 Battle Royale PvP',
            icon: Icons.lock_clock,
            buttonColor: const Color(0xFF1E1A24),
            borderColor: const Color(0xFF5A4838),
            textColor: AppColors.goldText.withValues(alpha: 0.7),
            isLocked: true,
            onTap: () => _showComingSoonDialog(context),
          ),
          const SizedBox(height: 6),

          // 4. GÖREVLER & ÖDÜLLER
          _buildMenuButton(
            title: '📋 GÖREVLER & ÖDÜLLER',
            subtitle: 'Haftalık Görevler • Elmas & Altın Kazan',
            icon: Icons.assignment_turned_in,
            buttonColor: const Color(0xFF3D2608),
            borderColor: AppColors.goldText,
            textColor: AppColors.goldText,
            onTap: () => QuestDialog.showQuestDialog(context),
          ),
          const SizedBox(height: 6),

          // 5. SİLAH VE MERMİ MAĞAZASI
          _buildMenuButton(
            title: '🛒 SİLAH & MERMİ MAĞAZASI',
            subtitle: 'Tabanca, Tüfek, Pompalı & Cephane Al',
            icon: Icons.shopping_bag,
            buttonColor: const Color(0xFF361210),
            borderColor: const Color(0xFFFF7043),
            textColor: const Color(0xFFFF7043),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (ctx) => const WeaponShopScreen()));
            },
          ),
          const SizedBox(height: 6),

          // 6. ATÖLYE VE GÜÇLENDİRME
          _buildMenuButton(
            title: '⚡ ATÖLYE & GÜÇLENDİRME',
            subtitle: 'Kazma, Çekiç & Maden Güçlendirmeleri',
            icon: Icons.hardware,
            buttonColor: const Color(0xFF2B1038),
            borderColor: const Color(0xFFE040FB),
            textColor: const Color(0xFFE040FB),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (ctx) => const ForgeScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color buttonColor,
    required Color borderColor,
    required Color textColor,
    bool isPrimary = false,
    bool isLocked = false,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: isPrimary ? 7.5 : (isLocked ? 5.5 : 6.0)),
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: isPrimary ? 1.8 : 1.2),
            boxShadow: [
              BoxShadow(
                color: borderColor.withValues(alpha: isPrimary ? 0.35 : (isLocked ? 0.08 : 0.18)),
                blurRadius: isPrimary ? 12 : 6,
                spreadRadius: isPrimary ? 1 : 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: textColor, size: isPrimary ? 19 : 17),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isLocked ? Colors.white70 : Colors.white,
                        fontSize: isPrimary ? 12.5 : 11.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: textColor.withValues(alpha: isLocked ? 0.7 : 0.9),
                        fontSize: 9.0,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                isLocked ? Icons.lock_outline : Icons.arrow_forward_ios,
                color: textColor.withValues(alpha: 0.7),
                size: 13,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
