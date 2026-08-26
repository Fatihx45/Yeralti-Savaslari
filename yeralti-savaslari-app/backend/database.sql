-- ==========================================================
-- Yeraltı Savaşları (Derin Kazı) - cPanel MySQL Veritabanı Şeması
-- Karakter Seti: UTF8MB4 (Emoji ve Türkçe Tam Uyumlu)
-- ==========================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 1. OYUNCULAR TABLOSU (PLAYERS)
CREATE TABLE IF NOT EXISTS `players` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `player_tag` VARCHAR(10) NOT NULL UNIQUE COMMENT '#5839 formatında benzersiz etiket',
  `username` VARCHAR(60) NOT NULL,
  `trophies` INT(11) NOT NULL DEFAULT 0,
  `unlocked_stage` INT(11) NOT NULL DEFAULT 1,
  `gold` INT(11) NOT NULL DEFAULT 100,
  `gems` INT(11) NOT NULL DEFAULT 10,
  `equipped_skin_id` VARCHAR(50) NOT NULL DEFAULT 'skin_miner_default',
  `status` ENUM('online', 'in_mining', 'offline') NOT NULL DEFAULT 'online',
  `last_seen` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_player_tag` (`player_tag`),
  INDEX `idx_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. ODALAR TABLOSU (ROOMS)
CREATE TABLE IF NOT EXISTS `rooms` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `room_code` VARCHAR(6) NOT NULL UNIQUE COMMENT '6 haneli oda şifresi örn: 749201',
  `room_name` VARCHAR(80) NOT NULL DEFAULT 'Volkanik Kazı Odası',
  `host_player_id` INT(11) NOT NULL,
  `mode` ENUM('coop', 'battle_royale') NOT NULL DEFAULT 'coop',
  `max_players` INT(11) NOT NULL DEFAULT 4,
  `stage_number` INT(11) NOT NULL DEFAULT 1,
  `stage_seed` INT(11) NOT NULL DEFAULT 12345 COMMENT 'Tüm oyuncuların aynı haritayı görmesini sağlayan tohum',
  `status` ENUM('waiting', 'in_game', 'finished') NOT NULL DEFAULT 'waiting',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_room_code` (`room_code`),
  INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. ODA OYUNCULARI TABLOSU (ROOM_PLAYERS)
CREATE TABLE IF NOT EXISTS `room_players` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `room_id` INT(11) NOT NULL,
  `player_id` INT(11) NOT NULL,
  `slot_index` INT(11) NOT NULL DEFAULT 0,
  `is_ready` TINYINT(1) NOT NULL DEFAULT 0,
  `current_hp` INT(11) NOT NULL DEFAULT 100,
  `max_hp` INT(11) NOT NULL DEFAULT 100,
  `score` INT(11) NOT NULL DEFAULT 0,
  `is_alive` TINYINT(1) NOT NULL DEFAULT 1,
  `last_ping` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_room_player_unique` (`room_id`, `player_id`),
  INDEX `idx_room_id` (`room_id`),
  INDEX `idx_player_id` (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. OYUN İÇİ CANLI OLAYLAR TABLOSU (GAME_EVENTS - CANLI SENKRONİZASYON)
CREATE TABLE IF NOT EXISTS `game_events` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `room_id` INT(11) NOT NULL,
  `sender_player_id` INT(11) NOT NULL,
  `event_type` ENUM('tile_hit', 'tile_broken', 'player_damaged', 'weapon_fire', 'emoji_reaction', 'stage_cleared') NOT NULL,
  `payload_json` TEXT NOT NULL COMMENT 'JSON formatında dinamik olay verisi',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_events_room_id` (`room_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. ARKADAŞLIK VE SOSYAL TABLOSU (FRIENDS)
CREATE TABLE IF NOT EXISTS `friends` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `player_id` INT(11) NOT NULL,
  `friend_id` INT(11) NOT NULL,
  `status` ENUM('pending', 'accepted', 'blocked') NOT NULL DEFAULT 'accepted',
  `gift_available` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_friends_unique` (`player_id`, `friend_id`),
  INDEX `idx_player_id` (`player_id`),
  INDEX `idx_friend_id` (`friend_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
