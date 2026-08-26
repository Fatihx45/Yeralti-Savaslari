class AppStrings {
  static String tr(String key, {String lang = 'tr'}) {
    final isEn = lang.toLowerCase() == 'en';
    final dict = isEn ? _en : _tr;
    return dict[key] ?? _tr[key] ?? key;
  }

  static const Map<String, String> _tr = {
    // Ana Menü
    'play_game': '🎮 OYUNA BAŞLA',
    'play_game_sub': 'Kaldığın Yer: Bölüm',
    'team_mining': '👥 EKİP KAZISI (1-10 KİŞİ)',
    'team_mining_sub': 'Sistem Madenci Botlarıyla Ortak Kazı & Bonus',
    'multiplayer_coming_soon': '🔒 ÇOK OYUNCULU (YAKIN GELECEKTE)',
    'multiplayer_sub': 'v1.1 Büyük Güncellemesi • 2-10 Battle Royale PvP',
    'quests_rewards': '📋 GÖREVLER & ÖDÜLLER',
    'quests_sub': 'Haftalık Görevler • Elmas & Altın Kazan',
    'weapon_shop': '🛒 SİLAH & MERMİ MAĞAZASI',
    'weapon_shop_sub': 'Tabanca, Tüfek, Pompalı & Cephane Al',
    'forge_upgrade': '⚡ ATÖLYE & GÜÇLENDİRME',
    'forge_sub': 'Kazma, Çekiç & Maden Güçlendirmeleri',
    'costumes': 'KOSTÜMLER',
    'friends': 'ARKADAŞLAR',
    'settings': 'AYARLAR',
    'profile': 'PROFİL',
    'captain': 'Kaptan',
    'stage': 'Bölüm',

    // Dil Seçimi
    'lang_switched': 'Dil değiştirildi: Türkçe 🇹🇷',

    // Bilgilendirme Diyaloğu
    'coming_soon_title': 'ÇOK OYUNCULU & ARKADAŞLAR',
    'coming_soon_badge': 'YAKIN GELECEKTE (v1.1 GÜNCELLEMESİ)',
    'coming_soon_desc': 'Gerçek zamanlı PvP Battle Royale, canlı 2-10 madenci düelloları ve oda kurup arkadaş çağırma sistemi v1.1 büyük güncellemesinde aktif edilecektir.',
    'got_it': 'ANLADIM ✅',

    // Oyun İçi HUD & Kontroller
    'dig_hit': 'KAZ / VUR',
    'fire': 'ATEŞ ET',
    'bag': 'ÇANTA',
    'shop': 'MAĞAZA',
    'reset': 'SIFIRLA',
    'hp': 'CAN',
    'energy': 'ENERJİ',
    'ammo': 'MERMİ',
    'depth': 'Derinlik',
    'boss_hp': 'BOSS CANI',

    // Diyaloglar
    'stage_completed': 'BÖLÜM TAMAMLANDI!',
    'next_stage': 'SONRAKİ BÖLÜME GEÇ ⏩',
    'item_found': 'YENİ EŞYA BULUNDU!',
    'item_found_sub': 'Bu eşyayı envanterinize almak istiyor musunuz?',
    'take_it': 'ALALIM ✅',
    'leave': 'BIRAK',

    // Çanta & Envanter
    'miner_backpack': 'MADENCİ ÇANTASI & ENVANTER',
    'copper': 'Bakır',
    'iron': 'Demir',
    'emeralds': 'Zümrüt',
    'fossils': 'Fosil',
    'sell_all': 'TÜMÜNÜ SAT (ALTIN DÖNÜŞTÜR)',
    'inventory_full': 'Çanta Dolu!',

    // Ayarlar
    'game_settings': 'OYUN AYARLARI',
    'activate_all_settings': '⚡ TÜM AYARLARI AKTİFLEŞTİR (100% SES & EFEKT)',
    'all_settings_activated': '⚡ Tüm sesler, titreşim ve bildirimler %100 aktif edildi!',
    'audio_vibration': '🔊 SES & TİTREŞİM',
    'sfx_volume': 'Efekt Sesi (SFX)',
    'music_volume': 'Müzik Sesi',
    'vibration': 'Titreşim (Haptic Feedback)',
    'vibration_sub': 'Kutu kazma ve patlamalarda titreşir',
    'notifications': '🔔 BİLDİRİMLER',
    'energy_full_notif': 'Enerji Dolumu',
    'energy_full_sub': 'Enerji tamamen dolunca haber ver',
    'weekly_quest_notif': 'Haftalık Görev Hatırlatıcı',
    'weekly_quest_sub': 'Görevler yenilendiğinde bildir',
    'room_invite_notif': 'Oda Daveti Bildirimi',
    'room_invite_sub': 'Arkadaşların seni odaya çağırdığında bildir',
    'language_region': '🌐 DİL & BÖLGE',
    'selected_language': 'Seçili Dil',
    'about': 'ℹ️ HAKKINDA',
    'game_version': 'Oyun Sürümü',
    'developer': 'Geliştirici',

    // Ekip Kazısı Lobisi
    'team_lobby_title': 'EKİP KAZISI LOBİSİ',
    'team_lobby_sub': 'Sistem Destekli 1-10 Madenci Kooperatif Modu',
    'team_capacity': '👥 TAKIM KAPASİTESİ:',
    'team_bonus': 'TAKIM TAMAMLAMA BONUSU:',
    'lobby_miners_ready': 'LOBİDEKİ MADENCİLER (HAZIR):',
    'invite_friend_id': 'ARKADAŞ ÇAĞIR (ID)',
    'invite_to_slot': '+ ID ile Arkadaşını Bu Slota Çağır',
    'start_team_mining': 'KİŞİLİK EKİP KAZISINI BAŞLAT',

    // Profil & Başarımlar
    'miner_profile': 'MADENCİ PROFİLİ',
    'player_tag': 'Oyuncu ID',
    'trophies': 'Kupa',
    'total_broken_tiles': 'Toplam Kırılan Kutu',
    'total_bosses_defeated': 'Yenilen Boss Sayısı',
    'total_monsters_killed': 'Yok Edilen Canavarlar',
    'badge_showcase': 'ROZET VİTRİNİ (MAX 3)',
    'achievements': 'BAŞARIMLAR & ÖDÜLLER',
    'claim_reward': 'ÖDÜLÜ AL',
    'claimed': 'ALINDI ✅',

    // Görevler
    'weekly_quests_title': 'HAFTALIK KADEMELİ GÖREVLER',
    'quests_reset_time': 'Görevler Her Pazartesi Yenilenir',
    'collect_reward': 'Ödülü Topla',
    'completed': 'TAMAMLANDI',

    // Mağaza & Silahlar
    'ammo_pack': 'Mermi Paketi',
    'buy': 'SATIN AL',
    'equipped': 'KUŞANILDI',
    'equip': 'KUŞAN',
    'upgrade': 'GÜÇLENDİR',
    'max_level': 'MAKSİMUM SEVİYE',
  };

  static const Map<String, String> _en = {
    // Main Menu
    'play_game': '🎮 PLAY GAME',
    'play_game_sub': 'Current Progress: Stage',
    'team_mining': '👥 TEAM MINING (1-10 PLAYERS)',
    'team_mining_sub': 'Co-op Mining & Bonus with AI Miner Bots',
    'multiplayer_coming_soon': '🔒 MULTIPLAYER (COMING SOON)',
    'multiplayer_sub': 'v1.1 Big Update • 2-10 Battle Royale PvP',
    'quests_rewards': '📋 QUESTS & REWARDS',
    'quests_sub': 'Weekly Quests • Earn Gems & Gold',
    'weapon_shop': '🛒 WEAPON & AMMO SHOP',
    'weapon_shop_sub': 'Buy Pistol, Rifle, Shotgun & Ammo',
    'forge_upgrade': '⚡ FORGE & UPGRADE',
    'forge_sub': 'Pickaxe, Hammer & Ore Upgrades',
    'costumes': 'SKINS',
    'friends': 'FRIENDS',
    'settings': 'SETTINGS',
    'profile': 'PROFILE',
    'captain': 'Captain',
    'stage': 'Stage',

    // Language Switch
    'lang_switched': 'Language switched: English 🇬🇧',

    // Coming Soon Dialog
    'coming_soon_title': 'MULTIPLAYER & FRIENDS',
    'coming_soon_badge': 'COMING SOON (v1.1 UPDATE)',
    'coming_soon_desc': 'Real-time PvP Battle Royale, live 2-10 miner duels and invite friend room system will be unlocked in v1.1 update.',
    'got_it': 'GOT IT ✅',

    // In-Game HUD & Controls
    'dig_hit': 'DIG / HIT',
    'fire': 'FIRE',
    'bag': 'BAG',
    'shop': 'SHOP',
    'reset': 'RESET',
    'hp': 'HP',
    'energy': 'ENERGY',
    'ammo': 'AMMO',
    'depth': 'Depth',
    'boss_hp': 'BOSS HP',

    // Dialogs
    'stage_completed': 'STAGE COMPLETED!',
    'next_stage': 'PROCEED TO NEXT STAGE ⏩',
    'item_found': 'NEW ITEM FOUND!',
    'item_found_sub': 'Do you want to add this item to your inventory?',
    'take_it': 'TAKE IT ✅',
    'leave': 'LEAVE',

    // Bag & Inventory
    'miner_backpack': 'MINER BACKPACK & INVENTORY',
    'copper': 'Copper',
    'iron': 'Iron',
    'emeralds': 'Emeralds',
    'fossils': 'Fossils',
    'sell_all': 'SELL ALL (CONVERT TO GOLD)',
    'inventory_full': 'Backpack Full!',

    // Settings
    'game_settings': 'GAME SETTINGS',
    'activate_all_settings': '⚡ ACTIVATE ALL SETTINGS (100% AUDIO & SFX)',
    'all_settings_activated': '⚡ All audio, vibrations and notifications are 100% enabled!',
    'audio_vibration': '🔊 AUDIO & VIBRATION',
    'sfx_volume': 'Sound Effects (SFX)',
    'music_volume': 'Music Volume',
    'vibration': 'Vibration (Haptic Feedback)',
    'vibration_sub': 'Vibrates on digging blocks and explosions',
    'notifications': '🔔 NOTIFICATIONS',
    'energy_full_notif': 'Energy Full',
    'energy_full_sub': 'Notify when energy is fully restored',
    'weekly_quest_notif': 'Weekly Quest Reminder',
    'weekly_quest_sub': 'Notify when quests are refreshed',
    'room_invite_notif': 'Room Invite Notification',
    'room_invite_sub': 'Notify when friends invite you to a room',
    'language_region': '🌐 LANGUAGE & REGION',
    'selected_language': 'Selected Language',
    'about': 'ℹ️ ABOUT',
    'game_version': 'Game Version',
    'developer': 'Developer',

    // Team Mining Lobby
    'team_lobby_title': 'TEAM MINING LOBBY',
    'team_lobby_sub': 'AI Supported 1-10 Miner Co-op Mode',
    'team_capacity': '👥 TEAM CAPACITY:',
    'team_bonus': 'TEAM COMPLETION BONUS:',
    'lobby_miners_ready': 'MINERS IN LOBBY (READY):',
    'invite_friend_id': 'INVITE FRIEND (ID)',
    'invite_to_slot': '+ Invite Friend to this Slot by ID',
    'start_team_mining': 'START TEAM MINING FOR',

    // Profile & Achievements
    'miner_profile': 'MINER PROFILE',
    'player_tag': 'Player Tag',
    'trophies': 'Trophies',
    'total_broken_tiles': 'Total Broken Blocks',
    'total_bosses_defeated': 'Bosses Defeated',
    'total_monsters_killed': 'Monsters Destroyed',
    'badge_showcase': 'BADGE SHOWCASE (MAX 3)',
    'achievements': 'ACHIEVEMENTS & REWARDS',
    'claim_reward': 'CLAIM REWARD',
    'claimed': 'CLAIMED ✅',

    // Quests
    'weekly_quests_title': 'WEEKLY TIERED QUESTS',
    'quests_reset_time': 'Quests Refresh Every Monday',
    'collect_reward': 'Collect Reward',
    'completed': 'COMPLETED',

    // Shop & Weapons
    'ammo_pack': 'Ammo Pack',
    'buy': 'BUY',
    'equipped': 'EQUIPPED',
    'equip': 'EQUIP',
    'upgrade': 'UPGRADE',
    'max_level': 'MAX LEVEL',
  };
}
