import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../mining/presentation/screens/mining_screen.dart';
import '../../../mining/application/game_notifier.dart';
import '../../application/lobby_notifier.dart';
import '../../domain/models/remote_player_model.dart';

class LobbyScreen extends ConsumerWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lobbyState = ref.watch(lobbyNotifierProvider);
    final room = lobbyState.currentRoom;

    if (room == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Aktif bir oda bulunamadı.', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Geri Dön'),
              ),
            ],
          ),
        ),
      );
    }

    final isHost = room.hostUid == lobbyState.myUid;
    final myPlayer = room.players.firstWhere(
      (p) => p.uid == lobbyState.myUid,
      orElse: () => room.players.first,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            ref.read(lobbyNotifierProvider.notifier).leaveRoom();
            Navigator.pop(context);
          },
        ),
        title: const Text('BEKLEME ODASI (LOBİ)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F28),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF2E2E68), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Oda Kodu ve Paylaşım Kartı
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16163A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.goldText.withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ODA KODU:', style: TextStyle(color: Color(0xFF8E8EAE), fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(
                            room.roomId,
                            style: const TextStyle(
                              color: AppColors.goldText,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E1038),
                          foregroundColor: AppColors.goldText,
                          side: const BorderSide(color: AppColors.goldText),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: room.roomId));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Oda kodu panoya kopyalandı!')),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('KOPYALA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 2. Katılan Oyuncular Başlığı
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Katılan Madenciler:',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A24),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.neonGreen),
                      ),
                      child: Text(
                        '${room.players.length} / ${room.maxPlayers} Oyuncu',
                        style: const TextStyle(color: AppColors.neonGreen, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 3. Oyuncu Listesi
                for (final player in room.players)
                  _buildPlayerLobbyCard(player, isCurrent: player.uid == lobbyState.myUid),

                const SizedBox(height: 24),

                // 4. Eylem Butonları
                Row(
                  children: [
                    // Hazır Ol Butonu
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: myPlayer.isReady ? AppColors.neonGreen : Colors.white70,
                          side: BorderSide(
                            color: myPlayer.isReady ? AppColors.neonGreen : const Color(0xFF383878),
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          ref.read(lobbyNotifierProvider.notifier).toggleReady();
                        },
                        icon: Icon(myPlayer.isReady ? Icons.check_circle : Icons.radio_button_unchecked, size: 18),
                        label: Text(
                          myPlayer.isReady ? 'HAZIRSINIZ' : 'HAZIR DEĞİL',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Host için "KAZIYA BAŞLA"
                    if (isHost)
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 6,
                          ),
                          onPressed: () {
                            ref.read(lobbyNotifierProvider.notifier).startMission();
                            ref.read(gameNotifierProvider.notifier).initMultiplayerTeam(
                              room.players,
                              seed: room.gridSeed,
                              stage: room.stage,
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (ctx) => const MiningScreen()),
                            );
                          },
                          icon: const Icon(Icons.play_arrow, size: 20),
                          label: const Text(
                            'KAZIYA BAŞLA',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerLobbyCard(RemotePlayerModel player, {required bool isCurrent}) {
    const List<Color> playerColors = [
      Color(0xFF00E5FF),
      Color(0xFFFF4081),
      Color(0xFF76FF03),
      Color(0xFFFFD600),
      Color(0xFFE040FB),
      Color(0xFFFF6E40),
    ];
    final color = playerColors[player.colorIndex % playerColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrent ? const Color(0xFF1E1E44) : const Color(0xFF141434),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCurrent ? AppColors.neonGreen : const Color(0xFF2A2A5A),
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Center(
              child: Text(
                player.displayName.isNotEmpty ? player.displayName[0].toUpperCase() : 'M',
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Text(
                  player.displayName,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                if (player.isHost) ...[
                  const SizedBox(width: 6),
                  const Text('👑 Host', style: TextStyle(color: AppColors.goldText, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
                if (isCurrent) ...[
                  const SizedBox(width: 6),
                  const Text('(Sen)', style: TextStyle(color: AppColors.neonGreen, fontSize: 11)),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: player.isReady ? const Color(0xFF1E3A24) : const Color(0xFF3A1A1A),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: player.isReady ? AppColors.neonGreen : const Color(0xFFFF5252),
                width: 1,
              ),
            ),
            child: Text(
              player.isReady ? 'HAZIR' : 'BEKLİYOR',
              style: TextStyle(
                color: player.isReady ? AppColors.neonGreen : const Color(0xFFFF5252),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
