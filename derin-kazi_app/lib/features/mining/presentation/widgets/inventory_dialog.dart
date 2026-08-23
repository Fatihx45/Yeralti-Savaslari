import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/game_notifier.dart';

class InventoryDialog extends ConsumerWidget {
  const InventoryDialog({super.key});

  static void showInventoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const InventoryDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameNotifierProvider);
    final player = gameState.player;

    final int totalSaleValue = (player.copper * 15) + (player.iron * 35) + (player.emeralds * 100);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F28),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF383878), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 20,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Başlık Çubuğu
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF181844),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
                border: Border(bottom: BorderSide(color: Color(0xFF383878), width: 1.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.backpack, color: AppColors.goldText, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'MADENCİ ÇANTASI & ENVANTER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // İçerik Listesi
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    // Madenler Tablosu
                    _buildItemCard(
                      icon: Icons.circle,
                      iconColor: const Color(0xFFFFB74D),
                      name: 'Bakır Cevheri (Cu)',
                      count: player.copper,
                      unitPrice: '15 🟡 / adet',
                      desc: 'Kaya bloklarından çıkarılan temel maden.',
                    ),
                    const SizedBox(height: 8),

                    _buildItemCard(
                      icon: Icons.square,
                      iconColor: const Color(0xFFCFD8DC),
                      name: 'Demir & Gümüş Külçesi (Fe)',
                      count: player.iron,
                      unitPrice: '35 🟡 / adet',
                      desc: 'Sert katmanlardan elde edilen dayanıklı metal.',
                    ),
                    const SizedBox(height: 8),

                    _buildItemCard(
                      icon: Icons.diamond,
                      iconColor: const Color(0xFF00E676),
                      name: 'Ham Zümrüt & Yakut',
                      count: player.emeralds,
                      unitPrice: '100 🟡 + 1 💎 / adet',
                      desc: 'Mücevher damarlarından çıkan nadir taşlar.',
                    ),
                    const SizedBox(height: 8),

                    _buildItemCard(
                      icon: Icons.whatshot,
                      iconColor: const Color(0xFFFF5252),
                      name: 'Dinamit (Bomba)',
                      count: player.dynamites,
                      unitPrice: '3x3 Patlayıcı',
                      desc: 'Kullanıldığında hedeflenen 3x3 alanı anında temizler.',
                      actionWidget: player.dynamites > 0
                          ? ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD32F2F),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                minimumSize: Size.zero,
                              ),
                              onPressed: () {
                                ref.read(gameNotifierProvider.notifier).useDynamite();
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.flash_on, size: 14),
                              label: const Text('PATLAT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            )
                          : null,
                    ),
                    const SizedBox(height: 8),

                    _buildItemCard(
                      icon: Icons.auto_awesome,
                      iconColor: const Color(0xFFFFD54F),
                      name: 'Antik Fosil & Eser',
                      count: player.fossils,
                      unitPrice: 'Koleksiyon',
                      desc: 'Derin kazılarda bulunan tarihi eserler.',
                    ),
                  ],
                ),
              ),
            ),

            // Alt Satış / Pazar Butonu
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Color(0xFF141438),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
                border: Border(top: BorderSide(color: Color(0xFF2E2E68), width: 1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Madenlerin Toplam Değeri:',
                          style: TextStyle(color: Color(0xFFB0B0D0), fontSize: 11),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$totalSaleValue 🟡 Altın',
                          style: const TextStyle(
                            color: AppColors.goldText,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: totalSaleValue > 0 ? const Color(0xFF2E7D32) : const Color(0xFF1C3820),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: totalSaleValue > 0 ? 6 : 0,
                    ),
                    onPressed: totalSaleValue > 0
                        ? () {
                            ref.read(gameNotifierProvider.notifier).sellAllOres();
                          }
                        : null,
                    icon: const Icon(Icons.monetization_on, size: 18),
                    label: const Text(
                      'HEPSİNİ SAT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
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

  Widget _buildItemCard({
    required IconData icon,
    required Color iconColor,
    required String name,
    required int count,
    required String unitPrice,
    required String desc,
    Widget? actionWidget,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF141434),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: count > 0 ? const Color(0xFF3E3E7A) : const Color(0xFF22224A),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: iconColor.withValues(alpha: 0.6), width: 1),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'x$count',
                      style: TextStyle(
                        color: count > 0 ? AppColors.neonGreen : const Color(0xFF6E6E8E),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      desc,
                      style: const TextStyle(color: Color(0xFF8E8EAE), fontSize: 10),
                    ),
                    Text(
                      unitPrice,
                      style: const TextStyle(
                        color: AppColors.goldText,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (actionWidget != null) ...[
            const SizedBox(width: 8),
            actionWidget,
          ],
        ],
      ),
    );
  }
}

