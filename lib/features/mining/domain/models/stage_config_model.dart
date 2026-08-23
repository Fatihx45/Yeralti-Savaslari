enum StageTier {
  easy,      // 1-50 (Kolay)
  medium,    // 51-200 (Orta)
  hard,      // 201-300 (Zor)
  expert,    // 301-400 (Uzman)
  chaos,     // 401-500 (Kaos)
}

enum BossType {
  none,
  miniBoss,
  biomeBoss,
  finalBoss,
}

class StageConfig {
  final int stage;
  final int depth;
  final String biomeName;
  final StageTier tier;
  final int rows;
  final int columns;
  final double hpMultiplier;
  final double rewardMultiplier;
  final double mineProbability;
  final double solidGoldProbability;
  final BossType bossType;
  final int bossHp;
  final String specialNote;

  const StageConfig({
    required this.stage,
    required this.depth,
    required this.biomeName,
    required this.tier,
    required this.rows,
    required this.columns,
    required this.hpMultiplier,
    required this.rewardMultiplier,
    required this.mineProbability,
    required this.solidGoldProbability,
    required this.bossType,
    required this.bossHp,
    required this.specialNote,
  });

  bool get isBossStage => bossType != BossType.none;
}

class StageConfigService {
  static StageConfig getConfig(int rawStage) {
    final int stage = rawStage.clamp(1, 500);
    final int depth = stage;

    // 1. Katman (Tier) ve Biyom Belirleme
    StageTier tier;
    String biomeName;
    double hpMultiplier;
    double rewardMultiplier;
    double mineProbability;
    double solidGoldProbability;
    String specialNote = '';

    if (stage <= 50) {
      tier = StageTier.easy;
      biomeName = 'Kızıl Toprak Vadisi';
      // 1.00x -> 1.15x
      final double progress = (stage - 1) / 49.0;
      hpMultiplier = 1.00 + (0.15 * progress);
      rewardMultiplier = 1.00 + (0.10 * progress);
      mineProbability = 0.10;
      solidGoldProbability = 0.12;
      specialNote = 'Öğretici Katman';
    } else if (stage <= 100) {
      tier = StageTier.medium;
      biomeName = 'Bakır Yamaçları';
      // 1.18x -> 1.30x
      final double progress = (stage - 51) / 49.0;
      hpMultiplier = 1.18 + (0.12 * progress);
      rewardMultiplier = 1.15 + (0.10 * progress);
      mineProbability = 0.18 + (0.02 * progress);
      solidGoldProbability = 0.12 + (0.02 * progress);
      specialNote = 'Bakır / Demir Dengesi';
    } else if (stage <= 150) {
      tier = StageTier.medium;
      biomeName = 'Kömür Galerileri';
      // 1.30x -> 1.43x
      final double progress = (stage - 101) / 49.0;
      hpMultiplier = 1.30 + (0.13 * progress);
      rewardMultiplier = 1.25 + (0.10 * progress);
      mineProbability = 0.20 + (0.02 * progress);
      solidGoldProbability = 0.14 + (0.01 * progress);
      specialNote = 'Zincirleme TNT Patlamaları';
    } else if (stage <= 200) {
      tier = StageTier.medium;
      biomeName = 'Demir Kemer';
      // 1.43x -> 1.55x
      final double progress = (stage - 151) / 49.0;
      hpMultiplier = 1.43 + (0.12 * progress);
      rewardMultiplier = 1.35 + (0.10 * progress);
      mineProbability = 0.22;
      solidGoldProbability = 0.16;
      specialNote = 'Yüksek Solid Gold Engeli';
    } else if (stage <= 250) {
      tier = StageTier.hard;
      biomeName = 'Zümrüt Mağaraları';
      // 1.60x -> 1.77x
      final double progress = (stage - 201) / 49.0;
      hpMultiplier = 1.60 + (0.17 * progress);
      rewardMultiplier = 1.55 + (0.15 * progress);
      mineProbability = 0.24;
      solidGoldProbability = 0.16;
      specialNote = '1.5x Zümrüt Oranı & Elmas Kazma';
    } else if (stage <= 300) {
      tier = StageTier.hard;
      biomeName = 'Obsidyen Yarıkları';
      // 1.78x -> 1.95x
      final double progress = (stage - 251) / 49.0;
      hpMultiplier = 1.78 + (0.17 * progress);
      rewardMultiplier = 1.70 + (0.15 * progress);
      mineProbability = 0.26;
      solidGoldProbability = 0.18;
      specialNote = 'Sert Kaya Dokusu (+%10)';
    } else if (stage <= 350) {
      tier = StageTier.expert;
      biomeName = 'Ejder Damarı';
      // 2.00x -> 2.17x
      final double progress = (stage - 301) / 49.0;
      hpMultiplier = 2.00 + (0.17 * progress);
      rewardMultiplier = 2.00 + (0.15 * progress);
      mineProbability = 0.28;
      solidGoldProbability = 0.18;
      specialNote = 'Nadir Alet Ödülleri (%8)';
    } else if (stage <= 400) {
      tier = StageTier.expert;
      biomeName = 'Buzul Çekirdeği';
      // 2.18x -> 2.35x
      final double progress = (stage - 351) / 49.0;
      hpMultiplier = 2.18 + (0.17 * progress);
      rewardMultiplier = 2.15 + (0.20 * progress);
      mineProbability = 0.30;
      solidGoldProbability = 0.20;
      specialNote = 'Kısık Enerji Ödülleri (-%20)';
    } else if (stage <= 450) {
      tier = StageTier.chaos;
      biomeName = 'Volkanik Uçurum';
      // 2.45x -> 2.82x
      final double progress = (stage - 401) / 49.0;
      hpMultiplier = 2.45 + (0.37 * progress);
      rewardMultiplier = 2.50 + (0.50 * progress);
      mineProbability = 0.32 + (0.02 * progress);
      solidGoldProbability = 0.22;
      specialNote = 'Tehlikeli Magma Tuzakları';
    } else {
      tier = StageTier.chaos;
      biomeName = "Titan'ın Kalbi";
      // 2.83x -> 3.20x
      final double progress = (stage - 451) / 49.0;
      hpMultiplier = 2.83 + (0.37 * progress);
      rewardMultiplier = 3.00 + (0.50 * progress);
      mineProbability = 0.35;
      solidGoldProbability = 0.24;
      specialNote = stage == 500 ? 'BÜYÜK TİTAN FINAL BOSS' : 'Kaosun Zirvesi';
    }

    // 2. Harita Boyutları (Satır x Sütun)
    int rows = 13;
    int cols = 23;
    if (stage >= 432) {
      rows = 17;
      cols = 31;
    } else if (stage >= 408) {
      rows = 17;
      cols = 29;
    } else if (stage >= 226) {
      rows = 17;
      cols = 27;
    } else if (stage >= 76) {
      rows = 15;
      cols = 25;
    }

    // 3. Boss Durumu ve Boss HP Hesabı
    BossType bossType = BossType.none;
    int bossHp = 0;

    if (stage == 500) {
      bossType = BossType.finalBoss;
      bossHp = 1120; // 350 * 3.20 ≈ 1120 HP
      specialNote = '👑 BÜYÜK TİTAN (FINAL BOSS)';
    } else if (stage % 50 == 0) {
      bossType = BossType.biomeBoss;
      bossHp = (500 * hpMultiplier).round();
      specialNote = '🏆 $biomeName Biyom Boss';
    } else if (stage % 10 == 0) {
      bossType = BossType.miniBoss;
      bossHp = (350 * hpMultiplier).round();
      specialNote = '⚔️ Mini-Boss Çekirdeği';
    }

    return StageConfig(
      stage: stage,
      depth: depth,
      biomeName: biomeName,
      tier: tier,
      rows: rows,
      columns: cols,
      hpMultiplier: hpMultiplier,
      rewardMultiplier: rewardMultiplier,
      mineProbability: mineProbability,
      solidGoldProbability: solidGoldProbability,
      bossType: bossType,
      bossHp: bossHp,
      specialNote: specialNote,
    );
  }
}
