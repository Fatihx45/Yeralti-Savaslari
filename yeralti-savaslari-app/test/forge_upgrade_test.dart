import 'package:flutter_test/flutter_test.dart';
import 'package:derin_kazi/features/mining/application/game_notifier.dart';
import 'package:derin_kazi/features/mining/domain/models/weapon_model.dart';
import 'package:derin_kazi/features/mining/domain/models/tool_model.dart';
import 'package:derin_kazi/core/audio/audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AudioService.isTestMode = true;

  group('Demirci / Forge Silah & Alet Güçlendirme Testleri', () {
    test('Başlangıçta tabanca ve kürek seviye 1 olmalı', () {
      final notifier = GameNotifier();
      expect(notifier.state.player.getWeaponLevel(WeaponType.pistol), 1);
      expect(notifier.state.player.getToolLevel(ToolType.shovel), 1);
      expect(notifier.state.player.getWeaponDamage(WeaponType.pistol), WeaponType.pistol.damage);
    });

    test('Yeterli maden olduğunda Tabanca Seviye 2 yapılabilmeli ve hasarı artmalı', () {
      final notifier = GameNotifier();
      notifier.state = notifier.state.copyWith(
        player: notifier.state.player.copyWith(
          gold: 1000,
          copper: 10,
        ),
      );

      final initialDamage = notifier.state.player.getWeaponDamage(WeaponType.pistol);
      final bool upgraded = notifier.upgradeWeapon(WeaponType.pistol);

      expect(upgraded, true);
      expect(notifier.state.player.getWeaponLevel(WeaponType.pistol), 2);
      expect(notifier.state.player.getWeaponDamage(WeaponType.pistol), initialDamage + 12);
      expect(notifier.state.player.gold, 1000 - 300);
      expect(notifier.state.player.copper, 10 - 3);
    });

    test('Yetersiz maden veya altın olduğunda güçlendirme reddedilmeli', () {
      final notifier = GameNotifier();
      notifier.state = notifier.state.copyWith(
        player: notifier.state.player.copyWith(
          gold: 50,
          copper: 0,
        ),
      );

      final bool upgraded = notifier.upgradeWeapon(WeaponType.pistol);
      expect(upgraded, false);
      expect(notifier.state.player.getWeaponLevel(WeaponType.pistol), 1);
    });

    test('Alet (Kazma) Seviye 2 yapıldığında kazma gücü ve pvp hasarı artmalı', () {
      final notifier = GameNotifier();
      notifier.state = notifier.state.copyWith(
        player: notifier.state.player.copyWith(
          gold: 1000,
          copper: 10,
          inventoryTools: [ToolType.pickaxe],
        ),
      );

      final initialTileDmg = notifier.state.player.getToolTileDamage(ToolType.pickaxe);
      final initialPvpDmg = notifier.state.player.getToolPvpDamage(ToolType.pickaxe);

      final bool upgraded = notifier.upgradeTool(ToolType.pickaxe);
      expect(upgraded, true);
      expect(notifier.state.player.getToolLevel(ToolType.pickaxe), 2);
      expect(notifier.state.player.getToolTileDamage(ToolType.pickaxe), initialTileDmg + 4);
      expect(notifier.state.player.getToolPvpDamage(ToolType.pickaxe), initialPvpDmg + 6);
      expect(notifier.state.player.gold, 1000 - 250);
      expect(notifier.state.player.copper, 10 - 2);
    });

    test('Maksimum seviyedeki (Seviye 5) silah daha fazla yükseltilememeli', () {
      final notifier = GameNotifier();
      final updatedLevels = Map<WeaponType, int>.from(notifier.state.player.weaponLevels);
      updatedLevels[WeaponType.rifle] = 5;

      notifier.state = notifier.state.copyWith(
        player: notifier.state.player.copyWith(
          gold: 50000,
          gems: 100,
          emeralds: 50,
          fossils: 20,
          weaponLevels: updatedLevels,
        ),
      );

      final bool upgraded = notifier.upgradeWeapon(WeaponType.rifle);
      expect(upgraded, false);
      expect(notifier.state.player.getWeaponLevel(WeaponType.rifle), 5);
    });
  });
}
