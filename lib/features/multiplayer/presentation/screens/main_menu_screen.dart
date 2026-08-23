import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../mining/presentation/screens/mining_screen.dart';
import '../../../mining/application/game_notifier.dart';
import 'create_room_screen.dart';
import 'join_room_screen.dart';
import 'lobby_screen.dart';
import '../../application/lobby_notifier.dart';
import '../../../cosmetics/presentation/screens/cosmetics_screen.dart';
import '../../../quests/presentation/widgets/quest_dialog.dart';

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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isLandscape = constraints.maxWidth > constraints.maxHeight;

            return Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isLandscape ? 820 : 460,
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
                child: isLandscape ? _buildLandscapeLayout() : _buildPortraitLayout(),
              ),
            );
          },
        ),
      ),
    );
  }

  // Yatay (Landscape) 2 Kolonlu Konsol Düzeni
  Widget _buildLandscapeLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Sol Kolon: Logo, Madenci Adı, Görevler & Kostümler
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.hardware, size: 44, color: AppColors.goldText),
                const SizedBox(height: 4),
                const Text(
                  'DERİN KAZI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const Text(
                  'Yeraltı Madencilik & Battle Royale',
                  style: TextStyle(color: Color(0xFF8E8EAE), fontSize: 10),
                ),
                const SizedBox(height: 14),

                // İsim Girişi
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Madenci Adınız',
                    labelStyle: const TextStyle(color: Color(0xFF8E8EAE), fontSize: 11),
                    prefixIcon: const Icon(Icons.person, color: AppColors.goldText, size: 18),
                    filled: true,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    fillColor: const Color(0xFF16163A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF2E2E68)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.neonGreen, width: 1.5),
                    ),
                  ),
                  onChanged: (val) {
                    ref.read(lobbyNotifierProvider.notifier).setPlayerName(val);
                  },
                ),
                const SizedBox(height: 12),

                // Görevler & Kostümler Butonları
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.goldText,
                          side: const BorderSide(color: AppColors.goldText),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.assignment, size: 16),
                        label: const Text('GÖREVLER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5)),
                        onPressed: () => QuestDialog.showQuestDialog(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFE040FB),
                          side: const BorderSide(color: Color(0xFFE040FB)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.palette, size: 16),
                        label: const Text('KOSTÜMLER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (ctx) => const CosmeticsScreen()),
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

        // Sağ Kolon: 4 Oyun Modu Butonları
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMenuButton(
                  title: 'SOLO KAZI',
                  subtitle: 'Tek Kişilik Madencilik & Boss Savaşı',
                  icon: Icons.person,
                  buttonColor: const Color(0xFF1E3A24),
                  borderColor: AppColors.neonGreen,
                  textColor: AppColors.neonGreen,
                  onTap: () {
                    ref.read(lobbyNotifierProvider.notifier).setPlayerName(_nameController.text);
                    ref.read(gameNotifierProvider.notifier).startSoloGame();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (ctx) => const MiningScreen()),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildMenuButton(
                  title: '🌐 MULTIPLAYER (ÇOK OYUNCULU)',
                  subtitle: '4 Kişilik Battle Royale Hayatta Kalma',
                  icon: Icons.sports_kabaddi,
                  buttonColor: const Color(0xFF381424),
                  borderColor: const Color(0xFFFF5252),
                  textColor: const Color(0xFFFF5252),
                  onTap: () {
                    ref.read(lobbyNotifierProvider.notifier).setPlayerName(_nameController.text);
                    ref.read(lobbyNotifierProvider.notifier).createRoom(maxPlayers: 4);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (ctx) => const LobbyScreen()),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildMenuButton(
                  title: 'EKİP KAZISI (ODA KUR)',
                  subtitle: '1-10 Kişilik Özel Arkadaş Odası',
                  icon: Icons.group_add,
                  buttonColor: const Color(0xFF2E1A0A),
                  borderColor: AppColors.goldText,
                  textColor: AppColors.goldText,
                  onTap: () {
                    ref.read(lobbyNotifierProvider.notifier).setPlayerName(_nameController.text);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (ctx) => const CreateRoomScreen()),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildMenuButton(
                  title: 'ODAYA KATIL',
                  subtitle: '6 Haneli Oda Kodu ile Bağlan',
                  icon: Icons.login,
                  buttonColor: const Color(0xFF1E1038),
                  borderColor: const Color(0xFFE040FB),
                  textColor: const Color(0xFFE040FB),
                  onTap: () {
                    ref.read(lobbyNotifierProvider.notifier).setPlayerName(_nameController.text);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (ctx) => const JoinRoomScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Dikey (Fallback) Düzen
  Widget _buildPortraitLayout() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.hardware, size: 48, color: AppColors.goldText),
          const SizedBox(height: 6),
          const Text(
            'DERİN KAZI',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              labelText: 'Madenci Adınız',
              labelStyle: const TextStyle(color: Color(0xFF8E8EAE), fontSize: 11),
              prefixIcon: const Icon(Icons.person, color: AppColors.goldText, size: 18),
              filled: true,
              fillColor: const Color(0xFF16163A),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onChanged: (val) => ref.read(lobbyNotifierProvider.notifier).setPlayerName(val),
          ),
          const SizedBox(height: 14),
          _buildMenuButton(
            title: 'SOLO KAZI',
            subtitle: 'Tek Kişilik Madencilik',
            icon: Icons.person,
            buttonColor: const Color(0xFF1E3A24),
            borderColor: AppColors.neonGreen,
            textColor: AppColors.neonGreen,
            onTap: () {
              ref.read(lobbyNotifierProvider.notifier).setPlayerName(_nameController.text);
              ref.read(gameNotifierProvider.notifier).startSoloGame();
              Navigator.push(context, MaterialPageRoute(builder: (ctx) => const MiningScreen()));
            },
          ),
          const SizedBox(height: 8),
          _buildMenuButton(
            title: '🌐 MULTIPLAYER (ÇOK OYUNCULU)',
            subtitle: '4 Kişilik Battle Royale',
            icon: Icons.sports_kabaddi,
            buttonColor: const Color(0xFF381424),
            borderColor: const Color(0xFFFF5252),
            textColor: const Color(0xFFFF5252),
            onTap: () {
              ref.read(lobbyNotifierProvider.notifier).setPlayerName(_nameController.text);
              ref.read(lobbyNotifierProvider.notifier).createRoom(maxPlayers: 4);
              Navigator.push(context, MaterialPageRoute(builder: (ctx) => const LobbyScreen()));
            },
          ),
          const SizedBox(height: 8),
          _buildMenuButton(
            title: 'EKİP KAZISI (ODA KUR)',
            subtitle: 'Özel Arkadaş Odası Kur',
            icon: Icons.group_add,
            buttonColor: const Color(0xFF2E1A0A),
            borderColor: AppColors.goldText,
            textColor: AppColors.goldText,
            onTap: () {
              ref.read(lobbyNotifierProvider.notifier).setPlayerName(_nameController.text);
              Navigator.push(context, MaterialPageRoute(builder: (ctx) => const CreateRoomScreen()));
            },
          ),
          const SizedBox(height: 8),
          _buildMenuButton(
            title: 'ODAYA KATIL',
            subtitle: '6 Haneli Kod ile Katıl',
            icon: Icons.login,
            buttonColor: const Color(0xFF1E1038),
            borderColor: const Color(0xFFE040FB),
            textColor: const Color(0xFFE040FB),
            onTap: () {
              ref.read(lobbyNotifierProvider.notifier).setPlayerName(_nameController.text);
              Navigator.push(context, MaterialPageRoute(builder: (ctx) => const JoinRoomScreen()));
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
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.3),
            boxShadow: [
              BoxShadow(
                color: borderColor.withValues(alpha: 0.2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: textColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.white70, fontSize: 9.5),
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
