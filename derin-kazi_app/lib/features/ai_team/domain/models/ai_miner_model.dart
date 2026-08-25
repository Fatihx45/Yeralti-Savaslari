import 'package:flutter/material.dart';
import 'package:derin_kazi/features/mining/domain/models/grid_model.dart';

enum AiMinerSpecialty {
  goldHunter, // Altın ve maden arayıcı
  bossBreaker, // Yüksek HP'li blok ve Boss kırıcı
  dynamiteExpert, // Patlayıcı ve alan açıcı
  speedDigger, // Hızlı kazıcı
}

class AiMinerModel {
  final String id;
  final String name;
  final Color color;
  final String avatarEmoji;
  final AiMinerSpecialty specialty;
  final int digPower;
  Position position;
  int tilesBroken;
  int totalDamageDealt;
  int earnedGold;
  int earnedGems;
  String? currentEmoji;
  DateTime? emojiExpiration;

  AiMinerModel({
    required this.id,
    required this.name,
    required this.color,
    required this.avatarEmoji,
    required this.specialty,
    this.digPower = 2,
    required this.position,
    this.tilesBroken = 0,
    this.totalDamageDealt = 0,
    this.earnedGold = 0,
    this.earnedGems = 0,
    this.currentEmoji,
    this.emojiExpiration,
  });

  AiMinerModel copyWith({
    String? id,
    String? name,
    Color? color,
    String? avatarEmoji,
    AiMinerSpecialty? specialty,
    int? digPower,
    Position? position,
    int? tilesBroken,
    int? totalDamageDealt,
    int? earnedGold,
    int? earnedGems,
    String? currentEmoji,
    DateTime? emojiExpiration,
  }) {
    return AiMinerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      specialty: specialty ?? this.specialty,
      digPower: digPower ?? this.digPower,
      position: position ?? this.position,
      tilesBroken: tilesBroken ?? this.tilesBroken,
      totalDamageDealt: totalDamageDealt ?? this.totalDamageDealt,
      earnedGold: earnedGold ?? this.earnedGold,
      earnedGems: earnedGems ?? this.earnedGems,
      currentEmoji: currentEmoji ?? this.currentEmoji,
      emojiExpiration: emojiExpiration ?? this.emojiExpiration,
    );
  }

  // 10 Farklı Hazır Bot Madenci Şablonu (PDF Dokümanı Bölüm 3.6 - 10 Sabit Palet)
  static List<AiMinerModel> getPresetMiners() {
    return [
      AiMinerModel(
        id: 'bot_1',
        name: 'Demir Kazma Ahmet',
        color: const Color(0xFF00E676), // Neon Yeşil
        avatarEmoji: '👷',
        specialty: AiMinerSpecialty.speedDigger,
        digPower: 2,
        position: const Position(1, 1),
      ),
      AiMinerModel(
        id: 'bot_2',
        name: 'Elmas Avcısı Can',
        color: const Color(0xFF00E5FF), // Camgöbeği
        avatarEmoji: '💎',
        specialty: AiMinerSpecialty.goldHunter,
        digPower: 3,
        position: const Position(1, 11),
      ),
      AiMinerModel(
        id: 'bot_3',
        name: 'Dinamitçi Zeynep',
        color: const Color(0xFFFF3D00), // Kızıl Lav
        avatarEmoji: '🧨',
        specialty: AiMinerSpecialty.dynamiteExpert,
        digPower: 4,
        position: const Position(21, 1),
      ),
      AiMinerModel(
        id: 'bot_4',
        name: 'Usta Madenci Kaya',
        color: const Color(0xFFFFD600), // Altın Sarısı
        avatarEmoji: '⛏️',
        specialty: AiMinerSpecialty.bossBreaker,
        digPower: 3,
        position: const Position(21, 11),
      ),
      AiMinerModel(
        id: 'bot_5',
        name: 'Gezgin Kazıcı Burak',
        color: const Color(0xFFE040FB), // Büyülü Mor
        avatarEmoji: '🧭',
        specialty: AiMinerSpecialty.goldHunter,
        digPower: 2,
        position: const Position(10, 1),
      ),
      AiMinerModel(
        id: 'bot_6',
        name: 'Kaya Delici Selin',
        color: const Color(0xFFFF4081), // Pembe Zırh
        avatarEmoji: '⚡',
        specialty: AiMinerSpecialty.bossBreaker,
        digPower: 3,
        position: const Position(10, 11),
      ),
      AiMinerModel(
        id: 'bot_7',
        name: 'Kristal Muhafızı Efe',
        color: const Color(0xFF7C4DFF), // Mor Muhafız
        avatarEmoji: '🛡️',
        specialty: AiMinerSpecialty.speedDigger,
        digPower: 2,
        position: const Position(5, 5),
      ),
      AiMinerModel(
        id: 'bot_8',
        name: 'Lav Ustası Kerem',
        color: const Color(0xFFFF6D00), // Turuncu Lav
        avatarEmoji: '🔥',
        specialty: AiMinerSpecialty.dynamiteExpert,
        digPower: 3,
        position: const Position(15, 5),
      ),
      AiMinerModel(
        id: 'bot_9',
        name: 'Zümrüt Gözlü Derya',
        color: const Color(0xFF1DE9B6), // Turkuaz
        avatarEmoji: '🟢',
        specialty: AiMinerSpecialty.goldHunter,
        digPower: 3,
        position: const Position(5, 9),
      ),
    ];
  }
}
