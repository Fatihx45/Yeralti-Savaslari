import 'tool_model.dart';

enum TileType {
  soil,
  rock,
  goldOre,
  solidGold, // Kırılmaz Sabit Sarı Blok
  potion,
  specialItem,
  chest,       // Hazine Sandığı (Büyük Altın & Elmas)
  tnt,         // Dinamit (3x3 Patlama)
  emeraldOre,  // Zümrüt & Değerli Taş Damarı
  bossCore,    // Büyük Titan Çekirdeği (500 HP - Zafer Bloğu)
  hiddenMine,  // Gizli Mayın (Dışarıdan Toprak Görünür - Patlayıcı)
  empty,
}

class TileModel {
  final String id;
  final TileType type;
  final int maxHp;
  final int currentHp;
  final int rewardGold;
  final int rewardGems;
  final int rewardEnergy;
  final int rewardHp; // 5 Can veya 10 Can
  final int rewardCopper;
  final int rewardIron;
  final int rewardEmerald;
  final int rewardFossil;
  final int rewardDynamite;
  final ToolType? rewardTool; // Bulunan envanter aleti
  final bool isCleared;

  const TileModel({
    required this.id,
    required this.type,
    required this.maxHp,
    required this.currentHp,
    this.rewardGold = 0,
    this.rewardGems = 0,
    this.rewardEnergy = 0,
    this.rewardHp = 0,
    this.rewardCopper = 0,
    this.rewardIron = 0,
    this.rewardEmerald = 0,
    this.rewardFossil = 0,
    this.rewardDynamite = 0,
    this.rewardTool,
    this.isCleared = false,
  });

  bool get isUnbreakable => type == TileType.solidGold;

  TileModel copyWith({
    String? id,
    TileType? type,
    int? maxHp,
    int? currentHp,
    int? rewardGold,
    int? rewardGems,
    int? rewardEnergy,
    int? rewardHp,
    int? rewardCopper,
    int? rewardIron,
    int? rewardEmerald,
    int? rewardFossil,
    int? rewardDynamite,
    ToolType? rewardTool,
    bool? isCleared,
  }) {
    return TileModel(
      id: id ?? this.id,
      type: type ?? this.type,
      maxHp: maxHp ?? this.maxHp,
      currentHp: currentHp ?? this.currentHp,
      rewardGold: rewardGold ?? this.rewardGold,
      rewardGems: rewardGems ?? this.rewardGems,
      rewardEnergy: rewardEnergy ?? this.rewardEnergy,
      rewardHp: rewardHp ?? this.rewardHp,
      rewardCopper: rewardCopper ?? this.rewardCopper,
      rewardIron: rewardIron ?? this.rewardIron,
      rewardEmerald: rewardEmerald ?? this.rewardEmerald,
      rewardFossil: rewardFossil ?? this.rewardFossil,
      rewardDynamite: rewardDynamite ?? this.rewardDynamite,
      rewardTool: rewardTool ?? this.rewardTool,
      isCleared: isCleared ?? this.isCleared,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'maxHp': maxHp,
      'currentHp': currentHp,
      'rewardGold': rewardGold,
      'rewardGems': rewardGems,
      'rewardEnergy': rewardEnergy,
      'rewardCopper': rewardCopper,
      'isCleared': isCleared,
    };
  }

  factory TileModel.fromJson(Map<String, dynamic> json) {
    return TileModel(
      id: json['id'] as String,
      type: TileType.values.byName(json['type'] as String),
      maxHp: json['maxHp'] as int,
      currentHp: json['currentHp'] as int,
      rewardGold: json['rewardGold'] as int? ?? 0,
      rewardGems: json['rewardGems'] as int? ?? 0,
      rewardEnergy: json['rewardEnergy'] as int? ?? 0,
      rewardCopper: json['rewardCopper'] as int? ?? 0,
      isCleared: json['isCleared'] as bool? ?? false,
    );
  }
}

