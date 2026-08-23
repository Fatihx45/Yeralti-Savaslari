import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../mining/application/game_notifier.dart';

class SkinOption {
  final String id;
  final String name;
  final String iconEmoji;
  final Color shirtColor;
  final Color pantsColor;
  final Color helmetColor;
  final int costGems;

  const SkinOption({
    required this.id,
    required this.name,
    required this.iconEmoji,
    required this.shirtColor,
    required this.pantsColor,
    required this.helmetColor,
    this.costGems = 0,
  });
}

const availableSkins = [
  SkinOption(
    id: 'default_blue',
    name: 'Klasik Madenci',
    iconEmoji: '👷',
    shirtColor: Color(0xFF1E88E5),
    pantsColor: Color(0xFFE53935),
    helmetColor: Color(0xFFFFD54F),
    costGems: 0,
  ),
  SkinOption(
    id: 'gold_knight',
    name: 'Altın Muhafız',
    iconEmoji: '🛡️',
    shirtColor: Color(0xFFFFD700),
    pantsColor: Color(0xFFB8860B),
    helmetColor: Color(0xFFFFF8DC),
    costGems: 5,
  ),
  SkinOption(
    id: 'lava_miner',
    name: 'Lav Savaşçısı',
    iconEmoji: '🔥',
    shirtColor: Color(0xFFFF3D00),
    pantsColor: Color(0xFF212121),
    helmetColor: Color(0xFFFF6E40),
    costGems: 10,
  ),
  SkinOption(
    id: 'emerald_guardian',
    name: 'Zümrüt Ustası',
    iconEmoji: '🟢',
    shirtColor: Color(0xFF00E676),
    pantsColor: Color(0xFF1B5E20),
    helmetColor: Color(0xFF69F0AE),
    costGems: 15,
  ),
  SkinOption(
    id: 'crystal_lord',
    name: 'Kristal Lordu',
    iconEmoji: '💎',
    shirtColor: Color(0xFF00E5FF),
    pantsColor: Color(0xFF006064),
    helmetColor: Color(0xFFE0F7FA),
    costGems: 25,
  ),
];

class CosmeticsScreen extends ConsumerWidget {
  const CosmeticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameNotifierProvider);
    final activeSkinId = gameState.player.equippedSkinId;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F28),
        title: const Text('KOSTÜMLER & SKİNLER', style: TextStyle(color: AppColors.goldText, fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Row(
                children: [
                  const Text('💎 ', style: TextStyle(fontSize: 14)),
                  Text('${gameState.player.gems}', style: const TextStyle(color: Color(0xFF4FC3F7), fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: availableSkins.length,
        itemBuilder: (context, index) {
          final skin = availableSkins[index];
          final bool isEquipped = skin.id == activeSkinId;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF141434),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isEquipped ? AppColors.neonGreen : const Color(0xFF2A2A5E),
                width: isEquipped ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Önizleme Kutusu
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A1C),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: skin.shirtColor, width: 2),
                  ),
                  child: Center(
                    child: Text(skin.iconEmoji, style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(skin.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(width: 12, height: 12, decoration: BoxDecoration(color: skin.helmetColor, shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Container(width: 12, height: 12, decoration: BoxDecoration(color: skin.shirtColor, shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Container(width: 12, height: 12, decoration: BoxDecoration(color: skin.pantsColor, shape: BoxShape.circle)),
                        ],
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEquipped ? AppColors.neonGreen : const Color(0xFF1E3A5F),
                    foregroundColor: isEquipped ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    ref.read(gameNotifierProvider.notifier).equipSkin(skin.id, skin.costGems);
                  },
                  child: Text(
                    isEquipped
                        ? 'KUŞANILDI'
                        : (skin.costGems == 0 ? 'KUŞAN' : '${skin.costGems} 💎 AL'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
