import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/game_notifier.dart';
import '../../domain/models/stage_config_model.dart';
import '../screens/mining_screen.dart';

class StageSelectScreen extends ConsumerStatefulWidget {
  const StageSelectScreen({super.key});

  @override
  ConsumerState<StageSelectScreen> createState() => _StageSelectScreenState();
}

class _StageSelectScreenState extends ConsumerState<StageSelectScreen> {
  int _selectedBiomeIndex = 0;

  final List<Map<String, dynamic>> _biomes = const [
    {'name': 'Kızıl Toprak Vadisi', 'start': 1, 'end': 50, 'color': Color(0xFF00E676), 'emoji': '🏜️'},
    {'name': 'Bakır Yamaçları', 'start': 51, 'end': 100, 'color': Color(0xFFFFB74D), 'emoji': '🟤'},
    {'name': 'Kömür Galerileri', 'start': 101, 'end': 150, 'color': Color(0xFF90A4AE), 'emoji': '⛏️'},
    {'name': 'Demir Kemer', 'start': 151, 'end': 200, 'color': Color(0xFFB0BEC5), 'emoji': '⚪'},
    {'name': 'Zümrüt Mağaraları', 'start': 201, 'end': 250, 'color': Color(0xFF69F0AE), 'emoji': '🟢'},
    {'name': 'Obsidyen Yarıkları', 'start': 251, 'end': 300, 'color': Color(0xFFBA68C8), 'emoji': '🔮'},
    {'name': 'Ejder Damarı', 'start': 301, 'end': 350, 'color': Color(0xFFFF5252), 'emoji': '🐉'},
    {'name': 'Buzul Çekirdeği', 'start': 351, 'end': 400, 'color': Color(0xFF4FC3F7), 'emoji': '❄️'},
    {'name': 'Volkanik Uçurum', 'start': 401, 'end': 450, 'color': Color(0xFFFF6E40), 'emoji': '🌋'},
    {'name': "Titan'ın Kalbi", 'start': 451, 'end': 500, 'color': Color(0xFFE040FB), 'emoji': '👑'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final unlocked = ref.read(gameNotifierProvider).player.unlockedStage;
      // Oyuncunun kaldığı biyomu otomatik seç
      for (int i = 0; i < _biomes.length; i++) {
        final int bStart = _biomes[i]['start'] as int;
        final int bEnd = _biomes[i]['end'] as int;
        if (unlocked >= bStart && unlocked <= bEnd) {
          setState(() {
            _selectedBiomeIndex = i;
          });
          break;
        }
      }
    });
  }

  void _launchStage(int stageNumber) {
    ref.read(gameNotifierProvider.notifier).startStage(stageNumber);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (ctx) => const MiningScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameNotifierProvider);
    final int unlockedStage = gameState.player.unlockedStage;
    final currentBiome = _biomes[_selectedBiomeIndex];
    final int startStage = currentBiome['start'] as int;
    final int endStage = currentBiome['end'] as int;
    final Color biomeColor = currentBiome['color'] as Color;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            children: [
              // 1. Üst Kontrol Çubuğu (Geri, Başlık, Hızlı Devam Butonu, Elmas/Altın)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'BÖLÜM SEÇİMİ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        '500 Bölüm • 10 Biyom',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // HIZLI DEVAM ET BUTONU
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lavaOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 6,
                    ),
                    icon: const Icon(Icons.play_arrow, size: 18, color: Colors.white),
                    label: Text(
                      'DEVAM ET (BÖLÜM $unlockedStage)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                    onPressed: () => _launchStage(unlockedStage),
                  ),
                  const SizedBox(width: 12),

                  // Bakiye Rozetleri
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.hudPanel,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF4A2518)),
                    ),
                    child: Row(
                      children: [
                        Text('💎 ${gameState.player.gems}', style: const TextStyle(color: AppColors.cyanText, fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Text('🟡 ${gameState.player.gold}', style: const TextStyle(color: AppColors.goldText, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 2. 10 Biyom Yatay Kaydırılabilir Sekmeler
              SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _biomes.length,
                  itemBuilder: (context, index) {
                    final biome = _biomes[index];
                    final bool isSelected = _selectedBiomeIndex == index;
                    final bool isBiomeUnlocked = unlockedStage >= (biome['start'] as int);
                    final Color color = biome['color'] as Color;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedBiomeIndex = index;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? color.withValues(alpha: 0.25) : AppColors.hudPanel,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? color : (isBiomeUnlocked ? const Color(0xFF4A2518) : Colors.white12),
                              width: isSelected ? 1.8 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(biome['emoji'] as String, style: const TextStyle(fontSize: 13)),
                              const SizedBox(width: 6),
                              Text(
                                '${biome['name']} (${biome['start']}-${biome['end']})',
                                style: TextStyle(
                                  color: isSelected ? Colors.white : (isBiomeUnlocked ? Colors.white70 : Colors.white30),
                                  fontSize: 10.5,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                              if (!isBiomeUnlocked) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.lock, size: 11, color: Colors.white30),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              // 3. Bölüm Kartları Grid (50 Bölüm)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.hudPanel,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: biomeColor.withValues(alpha: 0.3)),
                  ),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 10,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: endStage - startStage + 1,
                    itemBuilder: (context, index) {
                      final int stageNum = startStage + index;
                      final bool isUnlocked = stageNum <= unlockedStage;
                      final bool isCompleted = stageNum < unlockedStage;
                      final bool isCurrent = stageNum == unlockedStage;

                      final config = StageConfigService.getConfig(stageNum);
                      final bool isMiniBoss = config.bossType == BossType.miniBoss;
                      final bool isBiomeBoss = config.bossType == BossType.biomeBoss;
                      final bool isFinalBoss = config.bossType == BossType.finalBoss;

                      Color cardBg = AppColors.panelBox;
                      Color borderColor = const Color(0xFF4A2518);
                      Widget? badgeIcon;

                      if (!isUnlocked) {
                        cardBg = const Color(0xFF0C0812);
                        borderColor = Colors.white10;
                      } else if (isCurrent) {
                        cardBg = const Color(0xFF3E1A10);
                        borderColor = AppColors.lavaOrange;
                      } else if (isCompleted) {
                        cardBg = const Color(0xFF14241B);
                        borderColor = AppColors.neonGreen;
                      }

                      if (isFinalBoss) {
                        borderColor = const Color(0xFFE040FB);
                        badgeIcon = const Text('👑', style: TextStyle(fontSize: 10));
                      } else if (isBiomeBoss) {
                        borderColor = AppColors.goldText;
                        badgeIcon = const Text('🏆', style: TextStyle(fontSize: 10));
                      } else if (isMiniBoss) {
                        borderColor = const Color(0xFFFF5252);
                        badgeIcon = const Text('⚔️', style: TextStyle(fontSize: 9));
                      }

                      return InkWell(
                        onTap: isUnlocked ? () => _launchStage(stageNum) : null,
                        borderRadius: BorderRadius.circular(8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: borderColor,
                              width: isCurrent || isBiomeBoss || isFinalBoss ? 2 : 1,
                            ),
                            boxShadow: isCurrent
                                ? [
                                    BoxShadow(
                                      color: AppColors.neonGreen.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Boss Rozeti (Sağ Üst)
                              if (badgeIcon != null)
                                Positioned(
                                  top: 2,
                                  right: 3,
                                  child: badgeIcon,
                                ),

                              // Tamamlandı Rozeti (Sol Üst)
                              if (isCompleted)
                                const Positioned(
                                  top: 2,
                                  left: 3,
                                  child: Icon(Icons.check, size: 10, color: AppColors.neonGreen),
                                ),

                              // Kilit İkonu veya Bölüm Numarası
                              if (!isUnlocked)
                                const Icon(Icons.lock, size: 14, color: Colors.white24)
                              else
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$stageNum',
                                      style: TextStyle(
                                        color: isCurrent
                                            ? AppColors.neonGreen
                                            : (isCompleted ? Colors.white : Colors.white70),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (isCurrent)
                                      const Text(
                                        'AKTİF',
                                        style: TextStyle(
                                          color: AppColors.neonGreen,
                                          fontSize: 6.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
