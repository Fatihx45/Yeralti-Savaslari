import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../mining/presentation/screens/mining_screen.dart';
import '../../../mining/application/game_notifier.dart';
import 'create_room_screen.dart';
import 'join_room_screen.dart';
import '../../application/lobby_notifier.dart';

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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F28),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF2E2E68), width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonGreen.withValues(alpha: 0.15),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Oyun Logosu & Başlık
                const Icon(Icons.hardware, size: 56, color: AppColors.goldText),
                const SizedBox(height: 10),
                const Text(
                  'DERİN KAZI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Yeraltı Madencilik & Hazine Macerası',
                  style: TextStyle(color: Color(0xFF8E8EAE), fontSize: 12),
                ),
                const SizedBox(height: 24),

                // Oyuncu İsim Girişi
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Madenci Adınız',
                    labelStyle: const TextStyle(color: Color(0xFF8E8EAE)),
                    prefixIcon: const Icon(Icons.person, color: AppColors.goldText, size: 20),
                    filled: true,
                    fillColor: const Color(0xFF16163A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF2E2E68)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.neonGreen, width: 1.5),
                    ),
                  ),
                  onChanged: (val) {
                    ref.read(lobbyNotifierProvider.notifier).setPlayerName(val);
                  },
                ),
                const SizedBox(height: 28),

                // 1. SOLO KAZI BUTONU
                _buildMenuButton(
                  title: 'SOLO KAZI',
                  subtitle: 'Tek Kişilik Çevrimdışı Madencilik',
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
                const SizedBox(height: 14),

                // 2. EKİP KAZISI - ODA KUR
                _buildMenuButton(
                  title: 'EKİP KAZISI (ODA KUR)',
                  subtitle: '1-10 Kişilik Arkadaş Grubuyla Kaz',
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
                const SizedBox(height: 14),

                // 3. EKİP KAZISI - ODAYA KATIL
                _buildMenuButton(
                  title: 'ODAYA KATIL',
                  subtitle: 'Arkadaşının 6 Haneli Kodunu Gir',
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
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: borderColor.withValues(alpha: 0.25),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: textColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: textColor, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

