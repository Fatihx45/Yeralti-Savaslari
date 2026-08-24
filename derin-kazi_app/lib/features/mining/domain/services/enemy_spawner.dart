import 'dart:math';
import '../models/enemy_model.dart';
import '../models/grid_model.dart';
import '../models/stage_config_model.dart';

class EnemyDefinition {
  final String name;
  final String emoji;
  final EnemyCategory category;
  final int baseHp;
  final int baseDamage;
  final int baseGoldReward;
  final int baseGemsReward;

  const EnemyDefinition({
    required this.name,
    required this.emoji,
    required this.category,
    required this.baseHp,
    required this.baseDamage,
    required this.baseGoldReward,
    this.baseGemsReward = 0,
  });
}

class EnemySpawner {
  static List<EnemyModel> spawnForStage({
    required int stage,
    required int rows,
    required int columns,
    required Position playerPos,
    int? seed,
  }) {
    final StageConfig config = StageConfigService.getConfig(stage);
    final Random random = seed != null ? Random(seed) : Random(stage * 77);
    final List<EnemyModel> enemies = [];

    // Biyoma göre düşman havuzu
    final pool = _getEnemyPoolForStage(stage);
    final double hpMult = config.hpMultiplier;
    final double dmgMult = 1.0 + (stage * 0.005); // Bölüm arttıkça hasar artar

    // Düşman Sayısı Hesabı:
    // Kolay katmanda 2-3 düşman, ortalarda 3-5, kaos katmanında 4-6
    int enemyCount = 2;
    if (stage > 400) {
      enemyCount = 4 + random.nextInt(3); // 4-6
    } else if (stage > 200) {
      enemyCount = 3 + random.nextInt(3); // 3-5
    } else if (stage > 50) {
      enemyCount = 2 + random.nextInt(3); // 2-4
    } else {
      enemyCount = 2 + (stage > 20 ? 1 : 0); // 2-3
    }

    // Kullanılmış pozisyonları takip et (Oyuncudan en az 3 adım uzakta)
    final Set<String> occupiedPositions = {
      '${playerPos.row}_${playerPos.col}',
      '${playerPos.row + 1}_${playerPos.col}',
      '${playerPos.row - 1}_${playerPos.col}',
      '${playerPos.row}_${playerPos.col + 1}',
      '${playerPos.row}_${playerPos.col - 1}',
    };

    Position getRandomValidPosition() {
      for (int i = 0; i < 100; i++) {
        final r = 1 + random.nextInt(max(1, rows - 2));
        final c = 1 + random.nextInt(max(1, columns - 2));
        final key = '${r}_$c';

        // Oyuncuya mesafe kontrolü (Manhattan distance >= 3)
        final dist = (r - playerPos.row).abs() + (c - playerPos.col).abs();
        if (dist >= 3 && !occupiedPositions.contains(key)) {
          occupiedPositions.add(key);
          return Position(r, c);
        }
      }
      return Position(rows ~/ 2, columns - 2);
    }

    // 1. Boss Aşamasında ise Boss Ekle
    if (config.isBossStage || stage == 500) {
      final bossDef = pool.firstWhere(
        (e) => e.category == EnemyCategory.boss,
        orElse: () => pool.last,
      );

      final bossPos = Position(rows ~/ 2, columns ~/ 2);
      occupiedPositions.add('${bossPos.row}_${bossPos.col}');

      final int bossHp = config.bossHp > 0 ? config.bossHp : (bossDef.baseHp * hpMult * 1.5).round();
      final int bossDmg = (bossDef.baseDamage * dmgMult).round();

      enemies.add(EnemyModel(
        id: 'boss_$stage',
        name: bossDef.name,
        emoji: bossDef.emoji,
        category: EnemyCategory.boss,
        maxHp: bossHp,
        currentHp: bossHp,
        attackDamage: bossDmg,
        position: bossPos,
        rewardGold: ((stage == 500 ? 5000 : 800) * config.rewardMultiplier).round(),
        rewardGems: stage == 500 ? 50 : 15,
        rewardEnergy: 40,
        rewardHp: 20,
        canShoot: true,
        shootChance: 45,
        bulletDamage: (bossDmg * 0.8).round().clamp(6, 40),
      ));
    }

    // 2. Normal / Elit Düşmanları Ekle
    final normalDefs = pool.where((e) => e.category != EnemyCategory.boss).toList();

    for (int i = 0; i < enemyCount; i++) {
      final def = normalDefs[random.nextInt(normalDefs.length)];
      final pos = getRandomValidPosition();

      final int calcHp = max(24, (def.baseHp * hpMult * 1.3).round());
      final int calcDmg = max(3, (def.baseDamage * dmgMult).round());
      final int calcGold = ((def.baseGoldReward + stage * 2) * config.rewardMultiplier).round();
      final int calcGems = def.baseGemsReward > 0 ? def.baseGemsReward : (random.nextDouble() < 0.15 ? 1 : 0);
      final bool isElite = def.category == EnemyCategory.elite;
      final bool canShoot = isElite || (random.nextDouble() < 0.25);

      enemies.add(EnemyModel(
        id: 'enemy_${stage}_$i',
        name: def.name,
        emoji: def.emoji,
        category: def.category,
        maxHp: calcHp,
        currentHp: calcHp,
        attackDamage: calcDmg,
        position: pos,
        rewardGold: calcGold,
        rewardGems: calcGems,
        rewardEnergy: 10,
        rewardHp: random.nextDouble() < 0.2 ? 5 : 0,
        canShoot: canShoot,
        shootChance: isElite ? 35 : 20,
        bulletDamage: isElite ? (calcDmg * 0.75).round().clamp(5, 25) : (calcDmg * 0.6).round().clamp(3, 15),
      ));
    }

    return enemies;
  }

  static List<EnemyDefinition> _getEnemyPoolForStage(int stage) {
    if (stage <= 50) {
      // 1. Biyom: Kızıl Toprak Vadisi (1-50)
      return [
        const EnemyDefinition(name: 'Haydut Kazıcı', emoji: '👷', category: EnemyCategory.minion, baseHp: 18, baseDamage: 4, baseGoldReward: 25),
        const EnemyDefinition(name: 'Maden Sıçanı', emoji: '🐀', category: EnemyCategory.minion, baseHp: 12, baseDamage: 3, baseGoldReward: 20),
        const EnemyDefinition(name: 'Kaya Böceği', emoji: '🪲', category: EnemyCategory.minion, baseHp: 22, baseDamage: 5, baseGoldReward: 30),
        const EnemyDefinition(name: 'Haydut Muhafız', emoji: '🥷', category: EnemyCategory.elite, baseHp: 40, baseDamage: 8, baseGoldReward: 60),
        const EnemyDefinition(name: 'Kral Haydut', emoji: '👑', category: EnemyCategory.boss, baseHp: 250, baseDamage: 14, baseGoldReward: 500, baseGemsReward: 10),
      ];
    } else if (stage <= 100) {
      // 2. Biyom: Bakır Yamaçları (51-100)
      return [
        const EnemyDefinition(name: 'Bakır Savaşçısı', emoji: '🔨', category: EnemyCategory.minion, baseHp: 30, baseDamage: 6, baseGoldReward: 40),
        const EnemyDefinition(name: 'Mağara Yarasası', emoji: '🦇', category: EnemyCategory.minion, baseHp: 20, baseDamage: 5, baseGoldReward: 35),
        const EnemyDefinition(name: 'Zırhlı Kertenkele', emoji: '🦎', category: EnemyCategory.minion, baseHp: 38, baseDamage: 7, baseGoldReward: 45),
        const EnemyDefinition(name: 'Bakır Muhafız', emoji: '🛡️', category: EnemyCategory.elite, baseHp: 65, baseDamage: 10, baseGoldReward: 90),
        const EnemyDefinition(name: 'Bakır Kolos', emoji: '🗿', category: EnemyCategory.boss, baseHp: 380, baseDamage: 18, baseGoldReward: 800, baseGemsReward: 15),
      ];
    } else if (stage <= 150) {
      // 3. Biyom: Kömür Galerileri (101-150)
      return [
        const EnemyDefinition(name: 'Duman Ruhu', emoji: '💨', category: EnemyCategory.minion, baseHp: 40, baseDamage: 8, baseGoldReward: 55),
        const EnemyDefinition(name: 'Kömür Yılanı', emoji: '🐍', category: EnemyCategory.minion, baseHp: 35, baseDamage: 9, baseGoldReward: 50),
        const EnemyDefinition(name: 'Gölge Hayaleti', emoji: '👻', category: EnemyCategory.minion, baseHp: 48, baseDamage: 10, baseGoldReward: 65),
        const EnemyDefinition(name: 'Maden Şefi', emoji: '🦹', category: EnemyCategory.elite, baseHp: 85, baseDamage: 14, baseGoldReward: 130),
        const EnemyDefinition(name: 'Kömür Kraliçe Örümcek', emoji: '🕷️', category: EnemyCategory.boss, baseHp: 450, baseDamage: 22, baseGoldReward: 1100, baseGemsReward: 18),
      ];
    } else if (stage <= 200) {
      // 4. Biyom: Demir Kemer (151-200)
      return [
        const EnemyDefinition(name: 'Demir Asker', emoji: '⚔️', category: EnemyCategory.minion, baseHp: 55, baseDamage: 11, baseGoldReward: 70),
        const EnemyDefinition(name: 'Metal Akrep', emoji: '🦂', category: EnemyCategory.minion, baseHp: 48, baseDamage: 12, baseGoldReward: 75),
        const EnemyDefinition(name: 'Çelik Otomat', emoji: '🤖', category: EnemyCategory.minion, baseHp: 65, baseDamage: 13, baseGoldReward: 85),
        const EnemyDefinition(name: 'Demir Şövalye', emoji: '🛡️', category: EnemyCategory.elite, baseHp: 110, baseDamage: 18, baseGoldReward: 170),
        const EnemyDefinition(name: 'Demir Dev Golem', emoji: '🦾', category: EnemyCategory.boss, baseHp: 550, baseDamage: 26, baseGoldReward: 1500, baseGemsReward: 20),
      ];
    } else if (stage <= 250) {
      // 5. Biyom: Zümrüt Mağaraları (201-250)
      return [
        const EnemyDefinition(name: 'Kristal Timsah', emoji: '🐊', category: EnemyCategory.minion, baseHp: 70, baseDamage: 14, baseGoldReward: 95),
        const EnemyDefinition(name: 'Zümrüt Elfi', emoji: '🧝', category: EnemyCategory.minion, baseHp: 60, baseDamage: 16, baseGoldReward: 100),
        const EnemyDefinition(name: 'Zehirli Kristal Canavarı', emoji: '🍄', category: EnemyCategory.minion, baseHp: 80, baseDamage: 15, baseGoldReward: 110),
        const EnemyDefinition(name: 'Zümrüt Büyücüsü', emoji: '🧙', category: EnemyCategory.elite, baseHp: 135, baseDamage: 22, baseGoldReward: 220),
        const EnemyDefinition(name: 'Zümrüt İmparatoriçesi', emoji: '💎', category: EnemyCategory.boss, baseHp: 650, baseDamage: 30, baseGoldReward: 2000, baseGemsReward: 25),
      ];
    } else if (stage <= 300) {
      // 6. Biyom: Obsidyen Yarıkları (251-300)
      return [
        const EnemyDefinition(name: 'Obsidyen Örümcek', emoji: '🕷️', category: EnemyCategory.minion, baseHp: 85, baseDamage: 17, baseGoldReward: 120),
        const EnemyDefinition(name: 'Gölge İblisi', emoji: '👿', category: EnemyCategory.minion, baseHp: 95, baseDamage: 19, baseGoldReward: 130),
        const EnemyDefinition(name: 'Karanlık Suikastçı', emoji: '🥷', category: EnemyCategory.minion, baseHp: 80, baseDamage: 22, baseGoldReward: 140),
        const EnemyDefinition(name: 'Obsidyen Şeytanı', emoji: '👹', category: EnemyCategory.elite, baseHp: 160, baseDamage: 27, baseGoldReward: 280),
        const EnemyDefinition(name: 'Obsidyen Beholder', emoji: '👁️', category: EnemyCategory.boss, baseHp: 780, baseDamage: 36, baseGoldReward: 2600, baseGemsReward: 30),
      ];
    } else if (stage <= 350) {
      // 7. Biyom: Ejder Damarı (301-350)
      return [
        const EnemyDefinition(name: 'Ateş Ruhu', emoji: '🔥', category: EnemyCategory.minion, baseHp: 105, baseDamage: 21, baseGoldReward: 150),
        const EnemyDefinition(name: 'Ejder Yavrusu', emoji: '🦎', category: EnemyCategory.minion, baseHp: 115, baseDamage: 23, baseGoldReward: 165),
        const EnemyDefinition(name: 'Magma Ejderi', emoji: '🐉', category: EnemyCategory.minion, baseHp: 130, baseDamage: 25, baseGoldReward: 180),
        const EnemyDefinition(name: 'Lav Şövalyesi', emoji: '🗡️', category: EnemyCategory.elite, baseHp: 190, baseDamage: 32, baseGoldReward: 350),
        const EnemyDefinition(name: 'Kadim Kızıl Ejder', emoji: '🐲', category: EnemyCategory.boss, baseHp: 900, baseDamage: 42, baseGoldReward: 3200, baseGemsReward: 35),
      ];
    } else if (stage <= 400) {
      // 8. Biyom: Buzul Çekirdeği (351-400)
      return [
        const EnemyDefinition(name: 'Buz Golemi', emoji: '🧊', category: EnemyCategory.minion, baseHp: 130, baseDamage: 24, baseGoldReward: 180),
        const EnemyDefinition(name: 'Kutup Kurdu', emoji: '🐺', category: EnemyCategory.minion, baseHp: 115, baseDamage: 27, baseGoldReward: 190),
        const EnemyDefinition(name: 'Donmuş Ruh', emoji: '❄️', category: EnemyCategory.minion, baseHp: 140, baseDamage: 26, baseGoldReward: 210),
        const EnemyDefinition(name: 'Buz Muhafızı', emoji: '🤺', category: EnemyCategory.elite, baseHp: 220, baseDamage: 37, baseGoldReward: 420),
        const EnemyDefinition(name: 'Buzul Titanı', emoji: '🥶', category: EnemyCategory.boss, baseHp: 1050, baseDamage: 48, baseGoldReward: 4000, baseGemsReward: 40),
      ];
    } else if (stage <= 450) {
      // 9. Biyom: Volkanik Uçurum (401-450)
      return [
        const EnemyDefinition(name: 'Magma İfriti', emoji: '🌋', category: EnemyCategory.minion, baseHp: 155, baseDamage: 29, baseGoldReward: 220),
        const EnemyDefinition(name: 'Cehennem Tazısı', emoji: '🐕', category: EnemyCategory.minion, baseHp: 145, baseDamage: 32, baseGoldReward: 235),
        const EnemyDefinition(name: 'Lav Devi', emoji: '👹', category: EnemyCategory.minion, baseHp: 175, baseDamage: 31, baseGoldReward: 260),
        const EnemyDefinition(name: 'Lav Lordu', emoji: '🦹', category: EnemyCategory.elite, baseHp: 260, baseDamage: 44, baseGoldReward: 520),
        const EnemyDefinition(name: 'Volkan Tanrısı', emoji: '👺', category: EnemyCategory.boss, baseHp: 1200, baseDamage: 55, baseGoldReward: 5000, baseGemsReward: 45),
      ];
    } else {
      // 10. Biyom: Titan'ın Kalbi (451-500)
      return [
        const EnemyDefinition(name: 'Titan Savaşçısı', emoji: '💀', category: EnemyCategory.minion, baseHp: 185, baseDamage: 35, baseGoldReward: 280),
        const EnemyDefinition(name: 'Kaos İblisi', emoji: '👹', category: EnemyCategory.minion, baseHp: 170, baseDamage: 38, baseGoldReward: 300),
        const EnemyDefinition(name: 'Kıyamet Gardiyanı', emoji: '⚔️', category: EnemyCategory.minion, baseHp: 200, baseDamage: 36, baseGoldReward: 330),
        const EnemyDefinition(name: 'Titan Komutanı', emoji: '🦹', category: EnemyCategory.elite, baseHp: 320, baseDamage: 52, baseGoldReward: 650),
        const EnemyDefinition(name: 'BÜYÜK TİTAN (FINAL BOSS)', emoji: '👑', category: EnemyCategory.boss, baseHp: 1500, baseDamage: 65, baseGoldReward: 10000, baseGemsReward: 100),
      ];
    }
  }
}
