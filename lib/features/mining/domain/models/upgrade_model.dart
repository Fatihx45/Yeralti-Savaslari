enum UpgradeType {
  pickaxe, // Kazma
  hammer,  // Çekiç
  luck,    // Şans
  energy,  // Enerji
}

class UpgradeModel {
  final String id;
  final String name;
  final UpgradeType type;
  final int level;
  final int maxLevel;
  final int currentValue;
  final int nextValue;
  final int cost;
  final String description;

  const UpgradeModel({
    required this.id,
    required this.name,
    required this.type,
    required this.level,
    this.maxLevel = 5,
    required this.currentValue,
    required this.nextValue,
    required this.cost,
    required this.description,
  });

  bool get isMaxLevel => level >= maxLevel;

  UpgradeModel copyWith({
    String? id,
    String? name,
    UpgradeType? type,
    int? level,
    int? maxLevel,
    int? currentValue,
    int? nextValue,
    int? cost,
    String? description,
  }) {
    return UpgradeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      level: level ?? this.level,
      maxLevel: maxLevel ?? this.maxLevel,
      currentValue: currentValue ?? this.currentValue,
      nextValue: nextValue ?? this.nextValue,
      cost: cost ?? this.cost,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'level': level,
      'maxLevel': maxLevel,
      'currentValue': currentValue,
      'nextValue': nextValue,
      'cost': cost,
      'description': description,
    };
  }

  factory UpgradeModel.fromJson(Map<String, dynamic> json) {
    return UpgradeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: UpgradeType.values.byName(json['type'] as String),
      level: json['level'] as int,
      maxLevel: json['maxLevel'] as int? ?? 5,
      currentValue: json['currentValue'] as int,
      nextValue: json['nextValue'] as int,
      cost: json['cost'] as int,
      description: json['description'] as String,
    );
  }
}
