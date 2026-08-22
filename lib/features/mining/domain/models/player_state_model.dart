import 'upgrade_model.dart';
import 'tool_model.dart';

class PlayerStateModel {
  final int gold;
  final int gems;
  final int hp;
  final int maxHp;
  final int energy;
  final int maxEnergy;
  final int rank;
  final int lifetimeEarnings;
  final int copper;
  final int iron;
  final int emeralds;
  final int fossils;
  final int dynamites;
  final int highestDepth;
  final bool soundEnabled;
  final bool doubleBonusActive;
  final Map<UpgradeType, UpgradeModel> upgrades;
  final List<ToolType> inventoryTools;
  final int activeToolIndex;

  const PlayerStateModel({
    required this.gold,
    required this.gems,
    this.hp = 100,
    this.maxHp = 100,
    required this.energy,
    required this.maxEnergy,
    required this.rank,
    required this.lifetimeEarnings,
    this.copper = 0,
    this.iron = 0,
    this.emeralds = 0,
    this.fossils = 0,
    this.dynamites = 0,
    this.highestDepth = 1,
    this.soundEnabled = true,
    this.doubleBonusActive = false,
    required this.upgrades,
    this.inventoryTools = const [],
    this.activeToolIndex = 0,
  });

  ToolType? get activeTool {
    if (inventoryTools.isEmpty || activeToolIndex < 0 || activeToolIndex >= inventoryTools.length) {
      return null;
    }
    return inventoryTools[activeToolIndex];
  }

  int get tileDamageBonus {
    final tool = activeTool;
    return tool != null ? tool.tileDamage : 2; // Boş el: 2 hasar
  }

  int get pvpDamageBonus {
    final tool = activeTool;
    return tool != null ? tool.pvpDamage : 5; // Boş el yumruk: 5 hasar
  }

  bool get isAlive => hp > 0;

  PlayerStateModel copyWith({
    int? gold,
    int? gems,
    int? hp,
    int? maxHp,
    int? energy,
    int? maxEnergy,
    int? rank,
    int? lifetimeEarnings,
    int? copper,
    int? iron,
    int? emeralds,
    int? fossils,
    int? dynamites,
    int? highestDepth,
    bool? soundEnabled,
    bool? doubleBonusActive,
    Map<UpgradeType, UpgradeModel>? upgrades,
    List<ToolType>? inventoryTools,
    int? activeToolIndex,
  }) {
    return PlayerStateModel(
      gold: gold ?? this.gold,
      gems: gems ?? this.gems,
      hp: hp ?? this.hp,
      maxHp: maxHp ?? this.maxHp,
      energy: energy ?? this.energy,
      maxEnergy: maxEnergy ?? this.maxEnergy,
      rank: rank ?? this.rank,
      lifetimeEarnings: lifetimeEarnings ?? this.lifetimeEarnings,
      copper: copper ?? this.copper,
      iron: iron ?? this.iron,
      emeralds: emeralds ?? this.emeralds,
      fossils: fossils ?? this.fossils,
      dynamites: dynamites ?? this.dynamites,
      highestDepth: highestDepth ?? this.highestDepth,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      doubleBonusActive: doubleBonusActive ?? this.doubleBonusActive,
      upgrades: upgrades ?? this.upgrades,
      inventoryTools: inventoryTools ?? this.inventoryTools,
      activeToolIndex: activeToolIndex ?? this.activeToolIndex,
    );
  }

  static Map<UpgradeType, UpgradeModel> defaultUpgrades() {
    return {
      UpgradeType.pickaxe: const UpgradeModel(
        id: 'kazma',
        name: 'Kazma',
        type: UpgradeType.pickaxe,
        level: 4,
        maxLevel: 5,
        currentValue: 5,
        nextValue: 6,
        cost: 800,
        description: 'Hasar: 5 → 6',
      ),
      UpgradeType.hammer: const UpgradeModel(
        id: 'cekic',
        name: 'Çekiç',
        type: UpgradeType.hammer,
        level: 3,
        maxLevel: 5,
        currentValue: 9,
        nextValue: 12,
        cost: 800,
        description: 'Hasar: 9 → 12 (kaya)',
      ),
      UpgradeType.luck: const UpgradeModel(
        id: 'sans',
        name: 'Şans',
        type: UpgradeType.luck,
        level: 3,
        maxLevel: 5,
        currentValue: 15,
        nextValue: 20,
        cost: 600,
        description: 'Şans: +%15 altın bulma',
      ),
      UpgradeType.energy: const UpgradeModel(
        id: 'enerji',
        name: 'Enerji',
        type: UpgradeType.energy,
        level: 2,
        maxLevel: 5,
        currentValue: 80,
        nextValue: 95,
        cost: 320,
        description: 'Enerji: 80 → 95',
      ),
    };
  }

  factory PlayerStateModel.initial() {
    return PlayerStateModel(
      gold: 997,
      gems: 24,
      hp: 100,
      maxHp: 100,
      energy: 80,
      maxEnergy: 80,
      rank: 4,
      lifetimeEarnings: 3210,
      copper: 0,
      highestDepth: 93,
      soundEnabled: true,
      doubleBonusActive: false,
      upgrades: defaultUpgrades(),
    );
  }
}

