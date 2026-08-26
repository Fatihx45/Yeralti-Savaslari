import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../mining/application/game_notifier.dart';
import '../../../mining/domain/models/stage_config_model.dart';
import '../../../mining/presentation/screens/mining_screen.dart';
import 'package:derin_kazi/features/ai_team/application/ai_team_engine.dart';
import 'package:derin_kazi/features/ai_team/domain/models/ai_miner_model.dart';
import '../../../multiplayer/presentation/widgets/friend_invite_dialog.dart';

class TeamLobbyScreen extends ConsumerStatefulWidget {
  const TeamLobbyScreen({super.key});

  @override
  ConsumerState<TeamLobbyScreen> createState() => _TeamLobbyScreenState();
}

class _TeamLobbyScreenState extends ConsumerState<TeamLobbyScreen> {
  int _selectedTeamSize = 4;

  @override
  Widget build(BuildContext context) {
    final aiTeamState = ref.watch(aiTeamNotifierProvider);
    final gameState = ref.watch(gameNotifierProvider);
    final int unlockedStage = gameState.player.unlockedStage;
    final stageConfig = StageConfigService.getConfig(unlockedStage);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. ÜST BAR (Bazalt Taşı & Kor Ateşi Çerçeveli)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.hudPanel,
                border: Border(bottom: BorderSide(color: Color(0xFF4A2518), width: 1.5)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.groups, color: AppColors.lavaOrange, size: 24),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EKİP KAZISI LOBİSİ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Sistem Destekli 1-10 Madenci Kooperatif Modu',
                        style: TextStyle(color: AppColors.secondaryText, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. İÇERİK LİSTESİ
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // A. OYUNCU SAYISI SEÇİCİ KARTI (1-10 Slider)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.hudPanel,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF4A2518), width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '👥 TAKIM KAPASİTESİ:',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.lavaOrange.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.lavaOrange),
                              ),
                              child: Text(
                                '$_selectedTeamSize Kişi',
                                style: const TextStyle(color: AppColors.lavaOrange, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _selectedTeamSize.toDouble(),
                          min: 1,
                          max: 10,
                          divisions: 9,
                          activeColor: AppColors.lavaOrange,
                          inactiveColor: const Color(0xFF331C14),
                          onChanged: (val) {
                            setState(() {
                              _selectedTeamSize = val.round();
                            });
                            ref.read(aiTeamNotifierProvider.notifier).setTeamSize(_selectedTeamSize);
                          },
                        ),
                        Text(
                          '1 Oyuncu (Sen) + ${_selectedTeamSize - 1} Sistem Madenci Botu',
                          style: const TextStyle(color: AppColors.secondaryText, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // B. HARİTA VE TAKIM BONUSU BİLGİ KARTI
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF261808),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.goldText.withValues(alpha: 0.6)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.stars, color: AppColors.goldText, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TAKIM TAMAMLAMA BONUSU: +${(aiTeamState.teamBonusPercentage * 100).toInt()}%',
                                style: const TextStyle(color: AppColors.goldText, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              Text(
                                'Bölüm $unlockedStage • ${stageConfig.biomeName} (${stageConfig.rows}x${stageConfig.columns} Harita)',
                                style: const TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // C. LOBİDEKİ MADENCİLER LİSTESİ & ARKADAŞ ÇAĞIR BUTONU
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'LOBİDEKİ MADENCİLER (HAZIR):',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.8),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1D2838),
                          foregroundColor: AppColors.cyanText,
                          side: const BorderSide(color: AppColors.cyanText, width: 1.2),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.person_add, size: 15, color: AppColors.cyanText),
                        label: const Text('ARKADAŞ ÇAĞIR (ID)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                        onPressed: () => FriendInviteDialog.show(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 1. Oyuncu Kartı (Sen)
                  _buildMinerCard(
                    name: '${gameState.player.playerName} (Kaptan) [${gameState.player.playerTag}]',
                    emoji: '👑',
                    color: AppColors.goldText,
                    specialty: 'Takım Lideri',
                    isUser: true,
                  ),

                  // 2. Sistem ve Davet Edilen Madenciler
                  ...aiTeamState.activeMiners.map((bot) {
                    final isFriend = bot.name.contains('#');
                    return _buildMinerCard(
                      name: bot.name,
                      emoji: bot.avatarEmoji,
                      color: isFriend ? const Color(0xFF00E5FF) : bot.color,
                      specialty: isFriend ? '🤝 Davet Edilen Arkadaş' : _getSpecialtyTitle(bot.specialty),
                      isUser: false,
                    );
                  }),

                  // 3. Boş Kontenjan / Hızlı Arkadaş Ekle Kartı
                  if (aiTeamState.activeMiners.length < _selectedTeamSize - 1)
                    InkWell(
                      onTap: () => FriendInviteDialog.show(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF140D1A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.cyanText.withValues(alpha: 0.4), style: BorderStyle.solid),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline, color: AppColors.cyanText, size: 16),
                            SizedBox(width: 6),
                            Text(
                              '+ ID ile Arkadaşını Bu Slota Çağır',
                              style: TextStyle(color: AppColors.cyanText, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 3. ALT AKSİYON BUTONU (KAZIYI BAŞLAT)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.hudPanel,
                border: Border(top: BorderSide(color: Color(0xFF4A2518), width: 1.5)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lavaOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 8,
                  ),
                  icon: const Icon(Icons.play_arrow_rounded, size: 24, color: Colors.white),
                  label: Text(
                    '$_selectedTeamSize KİŞİLİK EKİP KAZISINI BAŞLAT',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1),
                  ),
                  onPressed: () {
                    ref.read(aiTeamNotifierProvider.notifier).startSimulation();
                    ref.read(gameNotifierProvider.notifier).startTeamMiningStage(_selectedTeamSize);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (ctx) => const MiningScreen()),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinerCard({
    required String name,
    required String emoji,
    required Color color,
    required String specialty,
    required bool isUser,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.hudPanel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1.5),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: isUser ? AppColors.goldText : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
                Text(
                  specialty,
                  style: const TextStyle(color: AppColors.secondaryText, fontSize: 10),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.neonGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.neonGreen, width: 1),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.neonGreen, size: 12),
                SizedBox(width: 4),
                Text('HAZIR', style: TextStyle(color: AppColors.neonGreen, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getSpecialtyTitle(AiMinerSpecialty specialty) {
    switch (specialty) {
      case AiMinerSpecialty.goldHunter:
        return '🔍 Değerli Maden Arayıcısı';
      case AiMinerSpecialty.bossBreaker:
        return '⚔️ Boss ve Sert Kaya Kırıcı';
      case AiMinerSpecialty.dynamiteExpert:
        return '💣 Dinamit & Alan Temizleyici';
      case AiMinerSpecialty.speedDigger:
        return '⚡ Hızlı Tünel Açıcı';
    }
  }
}
