import 'upgrade_model.dart';
import 'tool_model.dart';
import 'weapon_model.dart';

class PlayerStateModel {
  final String playerName;
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
  final int unlockedStage;
  final bool soundEnabled;
  final bool doubleBonusActive;
  final Map<UpgradeType, UpgradeModel> upgrades;
  final List<ToolType> inventoryTools;
  final int activeToolIndex;
  final String equippedSkinId;

  // Silah ve Mermi Sistemi Alanları
  final int currentAmmo;
  final WeaponType equippedWeapon;
  final List<WeaponType> ownedWeapons;
  final int maxInventorySlots;
  final int enemiesKilledTotal;
  final Map<WeaponType, int> weaponLevels;
  final Map<ToolType, int> toolLevels;

  // Yeni Ayarlar ve Profil Alanları (15 Alan)
  final double musicVolume;
  final double sfxVolume;
  final bool vibrationEnabled;
  final bool notificationsEnergyFull;
  final bool notificationsDailyQuest;
  final bool notificationsInvites;
  final String graphicsQuality; // 'low', 'medium', 'high'
  final bool batterySaverMode;
  final String languageCode;
  final bool adsPersonalized;
  final bool analyticsEnabled;
  final List<String> achievementIds;
  final List<String> showcaseBadgeIds; // Vitrinde sergilenen rozetler (Max 3)
  final int tilesBrokenTotal;
  final int bossesDefeatedTotal;
  final List<String> favoriteFriends;

  const PlayerStateModel({
    this.playerName = 'Madenci Usta',
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
    this.unlockedStage = 1,
    this.soundEnabled = true,
    this.doubleBonusActive = false,
    required this.upgrades,
    this.inventoryTools = const [],
    this.activeToolIndex = 0,
    this.equippedSkinId = 'default_blue',
    this.currentAmmo = 12,
    this.equippedWeapon = WeaponType.pistol,
    this.ownedWeapons = const [WeaponType.pistol],
    this.maxInventorySlots = 6,
    this.enemiesKilledTotal = 0,
    this.weaponLevels = const {
      WeaponType.pistol: 1,
      WeaponType.rifle: 1,
      WeaponType.shotgun: 1,
      WeaponType.laserGun: 1,
      WeaponType.rocketLauncher: 1,
    },
    this.toolLevels = const {
      ToolType.screwdriver: 1,
      ToolType.shovel: 1,
      ToolType.pickaxe: 1,
      ToolType.axe: 1,
      ToolType.baseballBat: 1,
      ToolType.diamondPick: 1,
    },
    this.musicVolume = 1.0,
    this.sfxVolume = 1.0,
    this.vibrationEnabled = true,
    this.notificationsEnergyFull = true,
    this.notificationsDailyQuest = true,
    this.notificationsInvites = true,
    this.graphicsQuality = 'high',
    this.batterySaverMode = false,
    this.languageCode = 'tr',
    this.adsPersonalized = true,
    this.analyticsEnabled = true,
    this.achievementIds = const [],
    this.showcaseBadgeIds = const ['ach_first_dig'],
    this.tilesBrokenTotal = 0,
    this.bossesDefeatedTotal = 0,
    this.favoriteFriends = const [],
  });

  int getWeaponLevel(WeaponType weapon) => weaponLevels[weapon] ?? 1;

  int getWeaponDamage(WeaponType weapon) {
    final lvl = getWeaponLevel(weapon);
    return weapon.damage + ((lvl - 1) * 12);
  }

  int getWeaponTileDamage(WeaponType weapon) {
    final lvl = getWeaponLevel(weapon);
    return weapon.tileDamage + ((lvl - 1) * 6);
  }

  int getWeaponMaxAmmo(WeaponType weapon) {
    final lvl = getWeaponLevel(weapon);
    return weapon.maxAmmo + ((lvl - 1) * 3);
  }

  int getToolLevel(ToolType tool) => toolLevels[tool] ?? 1;

  int getToolTileDamage(ToolType tool) {
    final lvl = getToolLevel(tool);
    return tool.tileDamage + ((lvl - 1) * 4);
  }

  int getToolPvpDamage(ToolType tool) {
    final lvl = getToolLevel(tool);
    return tool.pvpDamage + ((lvl - 1) * 6);
  }

  ToolType? get activeTool {
    if (inventoryTools.isEmpty || activeToolIndex < 0 || activeToolIndex >= inventoryTools.length) {
      return null;
    }
    return inventoryTools[activeToolIndex];
  }

  int get tileDamageBonus {
    final tool = activeTool;
    return tool != null ? getToolTileDamage(tool) : 2;
  }

  int get pvpDamageBonus {
    final tool = activeTool;
    return tool != null ? getToolPvpDamage(tool) : 15;
  }

  bool get isAlive => hp > 0;

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
      upgrades: defaultUpgrades(),
      inventoryTools: const [],
      activeToolIndex: 0,
      equippedSkinId: 'default_blue',
      unlockedStage: 1,
      currentAmmo: 12,
      equippedWeapon: WeaponType.pistol,
      ownedWeapons: const [WeaponType.pistol],
      maxInventorySlots: 6,
      enemiesKilledTotal: 0,
      weaponLevels: const {
        WeaponType.pistol: 1,
        WeaponType.rifle: 1,
        WeaponType.shotgun: 1,
        WeaponType.laserGun: 1,
        WeaponType.rocketLauncher: 1,
      },
      toolLevels: const {
        ToolType.screwdriver: 1,
        ToolType.shovel: 1,
        ToolType.pickaxe: 1,
        ToolType.axe: 1,
        ToolType.baseballBat: 1,
        ToolType.diamondPick: 1,
      },
    );
  }

  PlayerStateModel copyWith({
    String? playerName,
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
    int? unlockedStage,
    bool? soundEnabled,
    bool? doubleBonusActive,
    Map<UpgradeType, UpgradeModel>? upgrades,
    List<ToolType>? inventoryTools,
    int? activeToolIndex,
    String? equippedSkinId,
    int? currentAmmo,
    WeaponType? equippedWeapon,
    List<WeaponType>? ownedWeapons,
    int? maxInventorySlots,
    int? enemiesKilledTotal,
    Map<WeaponType, int>? weaponLevels,
    Map<ToolType, int>? toolLevels,
    double? musicVolume,
    double? sfxVolume,
    bool? vibrationEnabled,
    bool? notificationsEnergyFull,
    bool? notificationsDailyQuest,
    bool? notificationsInvites,
    String? graphicsQuality,
    bool? batterySaverMode,
    String? languageCode,
    bool? adsPersonalized,
    bool? analyticsEnabled,
    List<String>? achievementIds,
    List<String>? showcaseBadgeIds,
    int? tilesBrokenTotal,
    int? bossesDefeatedTotal,
    List<String>? favoriteFriends,
  }) {
    return PlayerStateModel(
      playerName: playerName ?? this.playerName,
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
      unlockedStage: unlockedStage ?? this.unlockedStage,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      doubleBonusActive: doubleBonusActive ?? this.doubleBonusActive,
      upgrades: upgrades ?? this.upgrades,
      inventoryTools: inventoryTools ?? this.inventoryTools,
      activeToolIndex: activeToolIndex ?? this.activeToolIndex,
      equippedSkinId: equippedSkinId ?? this.equippedSkinId,
      currentAmmo: currentAmmo ?? this.currentAmmo,
      equippedWeapon: equippedWeapon ?? this.equippedWeapon,
      ownedWeapons: ownedWeapons ?? this.ownedWeapons,
      maxInventorySlots: maxInventorySlots ?? this.maxInventorySlots,
      enemiesKilledTotal: enemiesKilledTotal ?? this.enemiesKilledTotal,
      weaponLevels: weaponLevels ?? this.weaponLevels,
      toolLevels: toolLevels ?? this.toolLevels,
      musicVolume: musicVolume ?? this.musicVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      notificationsEnergyFull: notificationsEnergyFull ?? this.notificationsEnergyFull,
      notificationsDailyQuest: notificationsDailyQuest ?? this.notificationsDailyQuest,
      notificationsInvites: notificationsInvites ?? this.notificationsInvites,
      graphicsQuality: graphicsQuality ?? this.graphicsQuality,
      batterySaverMode: batterySaverMode ?? this.batterySaverMode,
      languageCode: languageCode ?? this.languageCode,
      adsPersonalized: adsPersonalized ?? this.adsPersonalized,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      achievementIds: achievementIds ?? this.achievementIds,
      showcaseBadgeIds: showcaseBadgeIds ?? this.showcaseBadgeIds,
      tilesBrokenTotal: tilesBrokenTotal ?? this.tilesBrokenTotal,
      bossesDefeatedTotal: bossesDefeatedTotal ?? this.bossesDefeatedTotal,
      favoriteFriends: favoriteFriends ?? this.favoriteFriends,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerName': playerName,
      'gold': gold,
      'gems': gems,
      'hp': hp,
      'maxHp': maxHp,
      'energy': energy,
      'maxEnergy': maxEnergy,
      'rank': rank,
      'lifetimeEarnings': lifetimeEarnings,
      'copper': copper,
      'iron': iron,
      'emeralds': emeralds,
      'fossils': fossils,
      'dynamites': dynamites,
      'highestDepth': highestDepth,
      'unlockedStage': unlockedStage,
      'soundEnabled': soundEnabled,
      'doubleBonusActive': doubleBonusActive,
      'equippedSkinId': equippedSkinId,
      'inventoryTools': inventoryTools.map((t) => t.name).toList(),
      'activeToolIndex': activeToolIndex,
      'currentAmmo': currentAmmo,
      'equippedWeapon': equippedWeapon.name,
      'ownedWeapons': ownedWeapons.map((w) => w.name).toList(),
      'maxInventorySlots': maxInventorySlots,
      'enemiesKilledTotal': enemiesKilledTotal,
      'weaponLevels': weaponLevels.map((k, v) => MapEntry(k.name, v)),
      'toolLevels': toolLevels.map((k, v) => MapEntry(k.name, v)),
      'musicVolume': musicVolume,
      'sfxVolume': sfxVolume,
      'vibrationEnabled': vibrationEnabled,
      'notificationsEnergyFull': notificationsEnergyFull,
      'notificationsDailyQuest': notificationsDailyQuest,
      'notificationsInvites': notificationsInvites,
      'graphicsQuality': graphicsQuality,
      'batterySaverMode': batterySaverMode,
      'languageCode': languageCode,
      'adsPersonalized': adsPersonalized,
      'analyticsEnabled': analyticsEnabled,
      'achievementIds': achievementIds,
      'showcaseBadgeIds': showcaseBadgeIds,
      'tilesBrokenTotal': tilesBrokenTotal,
      'bossesDefeatedTotal': bossesDefeatedTotal,
      'favoriteFriends': favoriteFriends,
    };
  }

  factory PlayerStateModel.fromJson(Map<String, dynamic> json) {
    final List<ToolType> tools = [];
    if (json['inventoryTools'] != null) {
      for (final name in json['inventoryTools']) {
        try {
          tools.add(ToolType.values.firstWhere((t) => t.name == name));
        } catch (_) {}
      }
    }

    final List<WeaponType> weapons = [];
    if (json['ownedWeapons'] != null) {
      for (final name in json['ownedWeapons']) {
        try {
          weapons.add(WeaponType.values.firstWhere((w) => w.name == name));
        } catch (_) {}
      }
    }
    if (weapons.isEmpty) {
      weapons.add(WeaponType.pistol);
    }

    WeaponType currentWeapon = WeaponType.pistol;
    if (json['equippedWeapon'] != null) {
      try {
        currentWeapon = WeaponType.values.firstWhere((w) => w.name == json['equippedWeapon']);
      } catch (_) {}
    }

    final Map<WeaponType, int> wLevels = {
      WeaponType.pistol: 1,
      WeaponType.rifle: 1,
      WeaponType.shotgun: 1,
      WeaponType.laserGun: 1,
      WeaponType.rocketLauncher: 1,
    };
    if (json['weaponLevels'] != null && json['weaponLevels'] is Map) {
      final map = json['weaponLevels'] as Map;
      for (final entry in map.entries) {
        try {
          final w = WeaponType.values.firstWhere((t) => t.name == entry.key);
          wLevels[w] = (entry.value as num).toInt();
        } catch (_) {}
      }
    }

    final Map<ToolType, int> tLevels = {
      ToolType.screwdriver: 1,
      ToolType.shovel: 1,
      ToolType.pickaxe: 1,
      ToolType.axe: 1,
      ToolType.baseballBat: 1,
      ToolType.diamondPick: 1,
    };
    if (json['toolLevels'] != null && json['toolLevels'] is Map) {
      final map = json['toolLevels'] as Map;
      for (final entry in map.entries) {
        try {
          final t = ToolType.values.firstWhere((item) => item.name == entry.key);
          tLevels[t] = (entry.value as num).toInt();
        } catch (_) {}
      }
    }

    final List<String> loadedAchievements = [];
    if (json['achievementIds'] != null) {
      for (final a in json['achievementIds']) {
        loadedAchievements.add(a.toString());
      }
    }

    final List<String> loadedShowcase = [];
    if (json['showcaseBadgeIds'] != null) {
      for (final s in json['showcaseBadgeIds']) {
        loadedShowcase.add(s.toString());
      }
    }

    final List<String> loadedFriends = [];
    if (json['favoriteFriends'] != null) {
      for (final f in json['favoriteFriends']) {
        loadedFriends.add(f.toString());
      }
    }

    return PlayerStateModel(
      playerName: json['playerName'] as String? ?? 'Madenci Usta',
      gold: json['gold'] as int? ?? 997,
      gems: json['gems'] as int? ?? 24,
      hp: json['hp'] as int? ?? 100,
      maxHp: json['maxHp'] as int? ?? 100,
      energy: json['energy'] as int? ?? 80,
      maxEnergy: json['maxEnergy'] as int? ?? 80,
      rank: json['rank'] as int? ?? 4,
      lifetimeEarnings: json['lifetimeEarnings'] as int? ?? 3210,
      copper: json['copper'] as int? ?? 0,
      iron: json['iron'] as int? ?? 0,
      emeralds: json['emeralds'] as int? ?? 0,
      fossils: json['fossils'] as int? ?? 0,
      dynamites: json['dynamites'] as int? ?? 0,
      highestDepth: json['highestDepth'] as int? ?? 1,
      unlockedStage: json['unlockedStage'] as int? ?? 1,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      doubleBonusActive: json['doubleBonusActive'] as bool? ?? false,
      equippedSkinId: json['equippedSkinId'] as String? ?? 'default_blue',
      inventoryTools: tools,
      activeToolIndex: json['activeToolIndex'] as int? ?? 0,
      currentAmmo: json['currentAmmo'] as int? ?? 12,
      equippedWeapon: currentWeapon,
      ownedWeapons: weapons,
      maxInventorySlots: json['maxInventorySlots'] as int? ?? 6,
      enemiesKilledTotal: json['enemiesKilledTotal'] as int? ?? 0,
      musicVolume: (json['musicVolume'] as num?)?.toDouble() ?? 0.8,
      sfxVolume: (json['sfxVolume'] as num?)?.toDouble() ?? 1.0,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      notificationsEnergyFull: json['notificationsEnergyFull'] as bool? ?? true,
      notificationsDailyQuest: json['notificationsDailyQuest'] as bool? ?? true,
      notificationsInvites: json['notificationsInvites'] as bool? ?? true,
      graphicsQuality: json['graphicsQuality'] as String? ?? 'high',
      batterySaverMode: json['batterySaverMode'] as bool? ?? false,
      languageCode: json['languageCode'] as String? ?? 'tr',
      adsPersonalized: json['adsPersonalized'] as bool? ?? true,
      analyticsEnabled: json['analyticsEnabled'] as bool? ?? true,
      achievementIds: loadedAchievements,
      showcaseBadgeIds: loadedShowcase.isNotEmpty ? loadedShowcase : const ['ach_first_dig'],
      tilesBrokenTotal: json['tilesBrokenTotal'] as int? ?? 0,
      bossesDefeatedTotal: json['bossesDefeatedTotal'] as int? ?? 0,
      favoriteFriends: loadedFriends,
      upgrades: defaultUpgrades(),
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
}
