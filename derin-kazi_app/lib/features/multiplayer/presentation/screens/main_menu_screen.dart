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

class MainMenuScreen extends ConsumerStatefulWidget {
  const MainMenuScreen({super.key});

  @override
  ConsumerState<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends ConsumerState<MainMenuScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'Madenci Usta');

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameNotifierProvider);
    final int unlockedStage = gameState.player.unlockedStage;
    final stageConfig = StageConfigService.getConfig(unlockedStage);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isLandscape = constraints.maxWidth > constraints.maxHeight;

            return Stack(
              children: [
                Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: isLandscape ? 840 : 460,
                      maxHeight: isLandscape ? 400 : double.infinity,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F0F28),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFF2E2E68), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonGreen.withValues(alpha: 0.15),
                          blurRadius: 25,
                          spreadRadius: 2,
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
                        color: const Color(0xFF141438),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.goldText.withValues(alpha: 0.6)),
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
                          color: const Color(0xFF141438),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF2E2E68), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
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
                      const SizedBox(width: 6),

                      // 🛒 Mağaza Butonu
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (ctx) => const WeaponShopScreen()),
                          );
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2E1A0A), Color(0xFF5A3510)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.goldText, width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.goldText.withValues(alpha: 0.3),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('🛒', style: TextStyle(fontSize: 12)),
                              SizedBox(width: 4),
                              Text(
                                'MAĞAZA',
                                style: TextStyle(
                                  color: AppColors.goldText,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10.5,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),

                      // ⚡ Güçlendir / Atölye Butonu
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (ctx) => const ForgeScreen()),
                          );
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2E1345), Color(0xFF5C2068)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE040FB), width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE040FB).withValues(alpha: 0.3),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('⚡', style: TextStyle(fontSize: 12)),
                              SizedBox(width: 4),
                              Text(
                                'GÜÇLENDİR',
                                style: TextStyle(
                                  color: Color(0xFFE040FB),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10.5,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
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

  // Yatay (Landscape) 2 Kolonlu Konsol Düzeni
  Widget _buildLandscapeLayout(int unlockedStage, String biomeName, GameState gameState) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Sol Kolon: Resmi Logo Kartı, Madenci Bilgisi, Görevler & Kostümler
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🌋 RESMİ OYUN LOGOSU (LAV PARILTI EFEKTLİ)
                Container(
                  height: 125,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFFF6D00).withValues(alpha: 0.8), width: 1.8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF3D00).withValues(alpha: 0.35),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/image/logo.jpg',
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Madenci Bilgi Kartı (Sadece Okunur - Tıklanınca Profile Yönlendirir)
                InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (ctx) => const ProfileScreen()));
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141438),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2E2E68), width: 1.2),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0C0C22),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.neonGreen, width: 1.5),
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

                // Kostümler & Profil Butonları
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
                          backgroundColor: const Color(0xFF1E2E52),
                          foregroundColor: AppColors.cyanText,
                          side: const BorderSide(color: AppColors.cyanText, width: 1.2),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.account_circle, size: 16, color: AppColors.cyanText),
                        label: const Text('PROFİL & ROZET', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (ctx) => const ProfileScreen()),
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

        // İki Kolon Arası Dikey Çizgi
        Container(
          width: 1.2,
          height: double.infinity,
          color: const Color(0xFF242452),
          margin: const EdgeInsets.symmetric(horizontal: 4),
        ),

        // Sağ Kolon: 5 Oyun Modu Butonları (Kaydırılabilir & Taşmasız)
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
                    buttonColor: const Color(0xFF13381B),
                    borderColor: AppColors.neonGreen,
                    textColor: AppColors.neonGreen,
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

                  // 3. GÖREVLER & ÖDÜLLER
                  _buildMenuButton(
                    title: '📋 GÖREVLER & ÖDÜLLER',
                    subtitle: 'Haftalık Görevler • Elmas & Altın Kazan',
                    icon: Icons.assignment_turned_in,
                    buttonColor: const Color(0xFF2E2208),
                    borderColor: AppColors.goldText,
                    textColor: AppColors.goldText,
                    onTap: () => QuestDialog.showQuestDialog(context),
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
          // 🌋 RESMİ OYUN LOGOSU (LAV PARILTI EFEKTLİ)
          Container(
            height: 140,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFF6D00).withValues(alpha: 0.8), width: 1.8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF3D00).withValues(alpha: 0.35),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/image/logo.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Madenci Bilgi Kartı (Sadece Okunur - Tıklanınca Profile Yönlendirir)
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (ctx) => const ProfileScreen()));
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF141438),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2E2E68), width: 1.2),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C0C22),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.neonGreen, width: 1.5),
                    ),
                    child: const Center(
                      child: Icon(Icons.person, color: AppColors.goldText, size: 18),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          gameState.player.playerName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text(
                          'Profili Düzenle & Rozetler ➔',
                          style: TextStyle(
                            color: AppColors.goldText,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white38),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Görevler, Kostümler & Profil Butonları
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
                    backgroundColor: const Color(0xFF1E2E52),
                    foregroundColor: AppColors.cyanText,
                    side: const BorderSide(color: AppColors.cyanText, width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.account_circle, size: 16, color: AppColors.cyanText),
                  label: const Text('PROFİL & ROZET', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (ctx) => const ProfileScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildMenuButton(
            title: '🎮 OYUNA BAŞLA',
            subtitle: 'Kaldığın Yer: Bölüm $unlockedStage • $biomeName',
            icon: Icons.play_arrow_rounded,
            buttonColor: const Color(0xFF13381B),
            borderColor: AppColors.neonGreen,
            textColor: AppColors.neonGreen,
            isPrimary: true,
            onTap: () {
              ref.read(lobbyNotifierProvider.notifier).setPlayerName(_nameController.text);
              Navigator.push(context, MaterialPageRoute(builder: (ctx) => const StageSelectScreen()));
            },
          ),
          const SizedBox(height: 8),
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
          const SizedBox(height: 8),
          _buildMenuButton(
            title: '📋 GÖREVLER & ÖDÜLLER',
            subtitle: 'Haftalık Görevler • Elmas & Altın Kazan',
            icon: Icons.assignment_turned_in,
            buttonColor: const Color(0xFF2E2208),
            borderColor: AppColors.goldText,
            textColor: AppColors.goldText,
            onTap: () => QuestDialog.showQuestDialog(context),
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
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: isPrimary ? 8 : 6.5),
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: isPrimary ? 1.8 : 1.3),
            boxShadow: [
              BoxShadow(
                color: borderColor.withValues(alpha: isPrimary ? 0.35 : 0.18),
                blurRadius: isPrimary ? 12 : 8,
                spreadRadius: isPrimary ? 1 : 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: textColor, size: isPrimary ? 20 : 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isPrimary ? 13 : 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isPrimary ? AppColors.neonGreen.withValues(alpha: 0.85) : Colors.white70,
                        fontSize: 9.5,
                        fontWeight: isPrimary ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: textColor, size: 12),
            ],
          ),
        ),
      ),
    );
  }
}
