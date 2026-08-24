import 'package:flutter_test/flutter_test.dart';
import 'package:derin_kazi/features/mining/application/game_notifier.dart';
import 'package:derin_kazi/features/mining/domain/models/weapon_model.dart';
import 'package:derin_kazi/features/mining/domain/models/tool_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Silah, Mermi ve Mağaza Mantık Testleri', () {
    test('Başlangıçta oyuncunun tabancası ve 12 mermisi olmalı', () {
      final notifier = GameNotifier();
      expect(notifier.state.player.equippedWeapon, WeaponType.pistol);
      expect(notifier.state.player.currentAmmo, 12);
      expect(notifier.state.player.ownedWeapons.contains(WeaponType.pistol), true);
      expect(notifier.state.player.maxInventorySlots, 6);
    });

    test('fireWeapon çağrıldığında mermi 1 azalmalı', () {
      final notifier = GameNotifier();
      final initialAmmo = notifier.state.player.currentAmmo;
      notifier.fireWeapon();
      expect(notifier.state.player.currentAmmo, initialAmmo - 1);
    });

    test('Mağazadan Tüfek satın alınabilmeli, altın düşmeli ve cephane artmalı', () {
      final notifier = GameNotifier();
      // Oyuncuya yeterli altın ver
      notifier.state = notifier.state.copyWith(
        player: notifier.state.player.copyWith(gold: 2000),
      );

      final bool bought = notifier.buyWeapon(WeaponType.rifle);
      expect(bought, true);
      expect(notifier.state.player.ownedWeapons.contains(WeaponType.rifle), true);
      expect(notifier.state.player.equippedWeapon, WeaponType.rifle);
      expect(notifier.state.player.gold, 2000 - WeaponType.rifle.goldPrice);
    });

    test('Mermi paketi satın alma mermiyi artırmalı ve altın düşmeli', () {
      final notifier = GameNotifier();
      notifier.state = notifier.state.copyWith(
        player: notifier.state.player.copyWith(gold: 500, currentAmmo: 5),
      );

      final bool bought = notifier.buyAmmopack(15, 150);
      expect(bought, true);
      expect(notifier.state.player.currentAmmo, 20);
      expect(notifier.state.player.gold, 350);
    });

    test('Envanter çantası genişletme +2 slot eklemeli', () {
      final notifier = GameNotifier();
      notifier.state = notifier.state.copyWith(
        player: notifier.state.player.copyWith(gold: 1000, maxInventorySlots: 6),
      );

      final bool expanded = notifier.buyInventorySlotExpansion();
      expect(expanded, true);
      expect(notifier.state.player.maxInventorySlots, 8);
      expect(notifier.state.player.gold, 250);
    });

    test('Alet satın alma aleti envantere eklemeli', () {
      final notifier = GameNotifier();
      notifier.state = notifier.state.copyWith(
        player: notifier.state.player.copyWith(gold: 1000, inventoryTools: []),
      );

      final bool bought = notifier.buyTool(ToolType.shovel, 300);
      expect(bought, true);
      expect(notifier.state.player.inventoryTools.contains(ToolType.shovel), true);
      expect(notifier.state.player.gold, 700);
    });

    test('Bölüm onaylandığında sonraki aşamaya geçmeli ve +6 mermi yenilenmeli', () {
      final notifier = GameNotifier();
      final currentStage = notifier.state.grid.stage;
      final currentAmmo = notifier.state.player.currentAmmo;

      notifier.advanceStageConfirmed();
      expect(notifier.state.grid.stage, currentStage + 1);
      expect(notifier.state.player.currentAmmo, currentAmmo + 6);
      expect(notifier.state.showStageCompleteDialog, false);
    });

    test('Kutudan bulunan loot onaylandığında envantere eklenmeli', () {
      final notifier = GameNotifier();
      notifier.state = notifier.state.copyWith(
        pendingLootName: 'Pompalı 💥',
        pendingLootMessage: 'Pompalı bulundu! Alalım mı?',
        pendingLootWeapon: WeaponType.shotgun,
        pendingLootAmmo: 5,
      );

      notifier.acceptLoot();
      expect(notifier.state.player.ownedWeapons.contains(WeaponType.shotgun), true);
      expect(notifier.state.pendingLootName, null);
      expect(notifier.state.pendingLootMessage, null);
    });
  });
}
