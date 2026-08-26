import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/upgrade_model.dart';
import '../../application/game_notifier.dart';

class ShopPanel extends ConsumerWidget {
  final VoidCallback? onClose;

  const ShopPanel({super.key, this.onClose});

  static void showShopModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          top: 40,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: ShopPanel(onClose: () => Navigator.pop(ctx)),
          ),
        ),
      ),
    );
  }

  static void showShopDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: ShopPanel(onClose: () => Navigator.pop(ctx)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameNotifierProvider);
    final upgrades = gameState.player.upgrades;
    final gold = gameState.player.gold;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.shopPanel,
        border: Border.all(
          color: AppColors.neonGreen.withValues(alpha: 0.8),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonGreen.withValues(alpha: 0.2),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mağaza Başlığı + Kapat Butonu
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF1B1B4A),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(7),
                topRight: Radius.circular(7),
              ),
              border: Border(
                bottom: BorderSide(color: AppColors.neonGreen, width: 1.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.handyman, color: AppColors.neonGreen, size: 16),
                    const SizedBox(width: 8),
                    const Text(
                      'MAĞAZA & YÜKSELTMELER',
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                if (onClose != null)
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                    onPressed: onClose,
                  ),
              ],
            ),
          ),

          // Mevcut Altın Göstergesi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            color: const Color(0xFF101030),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mevcut Altın:',
                  style: TextStyle(color: Color(0xFFB0B0D0), fontSize: 11),
                ),
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.goldText,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$gold',
                      style: const TextStyle(
                        color: AppColors.goldText,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Yükseltme Kartları Listesi
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                _buildUpgradeCard(
                  context,
                  ref,
                  upgrades[UpgradeType.pickaxe]!,
                  gold,
                  Icons.hardware,
                ),
                const SizedBox(height: 8),
                _buildUpgradeCard(
                  context,
                  ref,
                  upgrades[UpgradeType.hammer]!,
                  gold,
                  Icons.construction,
                ),
                const SizedBox(height: 8),
                _buildUpgradeCard(
                  context,
                  ref,
                  upgrades[UpgradeType.luck]!,
                  gold,
                  Icons.eco,
                ),
                const SizedBox(height: 8),
                _buildUpgradeCard(
                  context,
                  ref,
                  upgrades[UpgradeType.energy]!,
                  gold,
                  Icons.bolt,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeCard(
    BuildContext context,
    WidgetRef ref,
    UpgradeModel upgrade,
    int currentGold,
    IconData iconData,
  ) {
    final bool canAfford = currentGold >= upgrade.cost && !upgrade.isMaxLevel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF14143D),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFF333377),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Üst Satır: İkon + İsim + Seviye
          Row(
            children: [
              Icon(iconData, color: AppColors.cyanText, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  upgrade.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                'Lv ${upgrade.level}/${upgrade.maxLevel}',
                style: const TextStyle(
                  color: AppColors.cyanText,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Orta Satır: Açıklama + Fiyat / Satın Al Butonu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  upgrade.description,
                  style: const TextStyle(
                    color: Color(0xFF90CAF9),
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: canAfford
                    ? () {
                        ref
                            .read(gameNotifierProvider.notifier)
                            .purchaseUpgrade(upgrade.type);
                      }
                    : null,
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: upgrade.isMaxLevel
                        ? const Color(0xFF2E2E4A)
                        : (canAfford
                            ? const Color(0xFF383810)
                            : const Color(0xFF202030)),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: canAfford ? AppColors.goldText : Colors.grey.shade700,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!upgrade.isMaxLevel) ...[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: canAfford ? AppColors.goldText : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                      ],
                      Text(
                        upgrade.isMaxLevel ? 'MAX' : '${upgrade.cost}',
                        style: TextStyle(
                          color: canAfford ? AppColors.goldText : Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Alt Satır: 5 Segmentli Seviye Barı
          Row(
            children: List.generate(upgrade.maxLevel, (index) {
              final isFilled = index < upgrade.level;
              return Expanded(
                child: Container(
                  height: 6,
                  margin: EdgeInsets.only(right: index < upgrade.maxLevel - 1 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: isFilled ? AppColors.levelBarFill : AppColors.levelBarEmpty,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

