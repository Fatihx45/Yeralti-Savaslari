enum ToolType {
  screwdriver, // Tornavida 🪛
  shovel,      // Kürek ⛏
  pickaxe,     // Kazma ⛏
  axe,         // Balta 🪓
  baseballBat, // Beyzbol Sopası 🏏
  diamondPick, // Elmas Kazma 💎
}

extension ToolTypeExtension on ToolType {
  String get displayName {
    switch (this) {
      case ToolType.screwdriver:
        return 'Tornavida';
      case ToolType.shovel:
        return 'Kürek';
      case ToolType.pickaxe:
        return 'Kazma';
      case ToolType.axe:
        return 'Balta';
      case ToolType.baseballBat:
        return 'Beyzbol Sopası';
      case ToolType.diamondPick:
        return 'Elmas Kazma';
    }
  }

  String get iconEmoji {
    switch (this) {
      case ToolType.screwdriver:
        return '🪛';
      case ToolType.shovel:
        return '⛏';
      case ToolType.pickaxe:
        return '⛏️';
      case ToolType.axe:
        return '🪓';
      case ToolType.baseballBat:
        return '🏏';
      case ToolType.diamondPick:
        return '💎';
    }
  }

  int get tileDamage {
    switch (this) {
      case ToolType.screwdriver:
        return 4;
      case ToolType.shovel:
        return 7;
      case ToolType.pickaxe:
        return 10;
      case ToolType.axe:
        return 8;
      case ToolType.baseballBat:
        return 5;
      case ToolType.diamondPick:
        return 20;
    }
  }

  int get pvpDamage {
    switch (this) {
      case ToolType.screwdriver:
        return 8;
      case ToolType.shovel:
        return 12;
      case ToolType.pickaxe:
        return 18;
      case ToolType.axe:
        return 20;
      case ToolType.baseballBat:
        return 22;
      case ToolType.diamondPick:
        return 30;
    }
  }
}
