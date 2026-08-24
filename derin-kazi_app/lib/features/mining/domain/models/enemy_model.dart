import 'grid_model.dart';

enum EnemyCategory {
  minion,      // Normal adam / canavar
  elite,       // Güçlü elit muhafız
  miniBoss,    // Mini boss
  boss,        // Biyom / Titan Boss
}

class EnemyModel {
  final String id;
  final String name;
  final String emoji;
  final EnemyCategory category;
  final int maxHp;
  final int currentHp;
  final int attackDamage;
  final Position position;
  final int rewardGold;
  final int rewardGems;
  final int rewardEnergy;
  final int rewardHp;
  final bool isAlive;
  final bool canShoot;
  final int shootChance;
  final int bulletDamage;

  const EnemyModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.maxHp,
    required this.currentHp,
    required this.attackDamage,
    required this.position,
    this.rewardGold = 20,
    this.rewardGems = 0,
    this.rewardEnergy = 5,
    this.rewardHp = 0,
    this.isAlive = true,
    this.canShoot = false,
    this.shootChance = 25,
    this.bulletDamage = 8,
  });

  bool get isBoss => category == EnemyCategory.boss || category == EnemyCategory.miniBoss;

  EnemyModel copyWith({
    String? id,
    String? name,
    String? emoji,
    EnemyCategory? category,
    int? maxHp,
    int? currentHp,
    int? attackDamage,
    Position? position,
    int? rewardGold,
    int? rewardGems,
    int? rewardEnergy,
    int? rewardHp,
    bool? isAlive,
    bool? canShoot,
    int? shootChance,
    int? bulletDamage,
  }) {
    return EnemyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      category: category ?? this.category,
      maxHp: maxHp ?? this.maxHp,
      currentHp: currentHp ?? this.currentHp,
      attackDamage: attackDamage ?? this.attackDamage,
      position: position ?? this.position,
      rewardGold: rewardGold ?? this.rewardGold,
      rewardGems: rewardGems ?? this.rewardGems,
      rewardEnergy: rewardEnergy ?? this.rewardEnergy,
      rewardHp: rewardHp ?? this.rewardHp,
      isAlive: isAlive ?? this.isAlive,
      canShoot: canShoot ?? this.canShoot,
      shootChance: shootChance ?? this.shootChance,
      bulletDamage: bulletDamage ?? this.bulletDamage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'category': category.name,
      'maxHp': maxHp,
      'currentHp': currentHp,
      'attackDamage': attackDamage,
      'row': position.row,
      'col': position.col,
      'rewardGold': rewardGold,
      'rewardGems': rewardGems,
      'rewardEnergy': rewardEnergy,
      'rewardHp': rewardHp,
      'isAlive': isAlive,
      'canShoot': canShoot,
      'shootChance': shootChance,
      'bulletDamage': bulletDamage,
    };
  }

  factory EnemyModel.fromJson(Map<String, dynamic> json) {
    return EnemyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      category: EnemyCategory.values.byName(json['category'] as String),
      maxHp: json['maxHp'] as int,
      currentHp: json['currentHp'] as int,
      attackDamage: json['attackDamage'] as int,
      position: Position(json['row'] as int, json['col'] as int),
      rewardGold: json['rewardGold'] as int? ?? 20,
      rewardGems: json['rewardGems'] as int? ?? 0,
      rewardEnergy: json['rewardEnergy'] as int? ?? 5,
      rewardHp: json['rewardHp'] as int? ?? 0,
      isAlive: json['isAlive'] as bool? ?? true,
      canShoot: json['canShoot'] as bool? ?? false,
      shootChance: json['shootChance'] as int? ?? 25,
      bulletDamage: json['bulletDamage'] as int? ?? 8,
    );
  }
}
