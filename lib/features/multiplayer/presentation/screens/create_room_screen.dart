import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/lobby_notifier.dart';
import 'lobby_screen.dart';

class CreateRoomScreen extends ConsumerStatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  ConsumerState<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends ConsumerState<CreateRoomScreen> {
  int _playerCount = 4; // Dokümanda önerilen varsayılan değer: 4

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('EKİP KAZISI OLUŞTUR', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F28),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF2E2E68), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.groups, color: AppColors.goldText, size: 28),
                    SizedBox(width: 10),
                    Text(
                      'Oda Ayarları',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Odanıza katılacak maksimum oyuncu sayısını belirleyin (1 - 10 Oyuncu):',
                  style: TextStyle(color: Color(0xFF8E8EAE), fontSize: 12),
                ),
                const SizedBox(height: 24),

                // Oyuncu Sayısı Sayacı & Slider
                Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            style: IconButton.styleFrom(backgroundColor: const Color(0xFF1C1C44)),
                            icon: const Icon(Icons.remove, color: Colors.white),
                            onPressed: _playerCount > 1 ? () => setState(() => _playerCount--) : null,
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1038),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.goldText, width: 2),
                            ),
                            child: Text(
                              '$_playerCount OYUNCU',
                              style: const TextStyle(
                                color: AppColors.goldText,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            style: IconButton.styleFrom(backgroundColor: const Color(0xFF1C1C44)),
                            icon: const Icon(Icons.add, color: Colors.white),
                            onPressed: _playerCount < 10 ? () => setState(() => _playerCount++) : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Slider(
                        value: _playerCount.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        activeColor: AppColors.goldText,
                        inactiveColor: const Color(0xFF2E2E68),
                        onChanged: (val) => setState(() => _playerCount = val.round()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Bilgilendirme Kutusu
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16163A),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.cyanText, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _playerCount >= 8
                              ? 'Büyük Grup (17×31 Izgara & %35 Takım Bonusu)'
                              : _playerCount >= 6
                                  ? 'Genişletilmiş Grup (17×27 Izgara & %25 Takım Bonusu)'
                                  : 'Standart Grup (13×23 Izgara & Katkı Oranlı Kazanç)',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Oda Oluştur Butonu
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 6,
                    ),
                    onPressed: () {
                      ref.read(lobbyNotifierProvider.notifier).createRoom(maxPlayers: _playerCount);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (ctx) => const LobbyScreen()),
                      );
                    },
                    icon: const Icon(Icons.meeting_room, size: 20),
                    label: const Text(
                      'ODAYI OLUŞTUR VE LOBİYE GEÇ',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
