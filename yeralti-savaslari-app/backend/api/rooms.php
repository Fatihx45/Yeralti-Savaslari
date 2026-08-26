<?php
// ==========================================================
// Yeraltı Savaşları - Lobi & 6 Haneli Oda API'si
// ==========================================================

require_once __DIR__ . '/../config/database.php';

$db = (new Database())->getConnection();
$input = Database::getJsonInput();
$action = $_GET['action'] ?? $input['action'] ?? 'list_rooms';

// 1. Bekleyen Odaları Listele
if ($action === 'list_rooms') {
    $stmt = $db->query("
        SELECT 
            r.*, p.username as host_name, p.player_tag as host_tag,
            (SELECT COUNT(*) FROM room_players rp WHERE rp.room_id = r.id) as current_players
        FROM rooms r
        JOIN players p ON r.host_player_id = p.id
        WHERE r.status = 'waiting'
        ORDER BY r.created_at DESC
        LIMIT 20
    ");
    $rooms = $stmt->fetchAll();

    Database::sendResponse(true, "Odalar listelendi.", $rooms);
}

// 2. Yeni Oda Oluştur (6 Haneli Kod ile)
if ($action === 'create_room') {
    $hostPlayerId = (int)($input['player_id'] ?? 0);
    $roomName = trim($input['room_name'] ?? 'Volkanik Kazı Odası');
    $mode = in_array($input['mode'] ?? '', ['coop', 'battle_royale']) ? $input['mode'] : 'coop';
    $maxPlayers = (int)($input['max_players'] ?? 4);
    $stageNumber = (int)($input['stage_number'] ?? 1);
    $stageSeed = (int)($input['stage_seed'] ?? rand(10000, 99999));

    if ($hostPlayerId <= 0) {
        Database::sendResponse(false, "Geçersiz kurucu oyuncu.", null, 400);
    }

    // 6 haneli benzersiz kod üret (Örn: 489210)
    $roomCode = '';
    $attempts = 0;
    do {
        $roomCode = (string)rand(100000, 999999);
        $check = $db->prepare("SELECT id FROM rooms WHERE room_code = :code AND status != 'finished' LIMIT 1");
        $check->execute([':code' => $roomCode]);
        $attempts++;
    } while ($check->fetch() && $attempts < 20);

    // Odayı kaydet
    $insertRoom = $db->prepare("
        INSERT INTO rooms (room_code, room_name, host_player_id, mode, max_players, stage_number, stage_seed, status)
        VALUES (:code, :name, :host, :mode, :max_p, :stage, :seed, 'waiting')
    ");
    $insertRoom->execute([
        ':code' => $roomCode,
        ':name' => $roomName,
        ':host' => $hostPlayerId,
        ':mode' => $mode,
        ':max_p' => $maxPlayers,
        ':stage' => $stageNumber,
        ':seed' => $stageSeed,
    ]);

    $roomId = (int)$db->lastInsertId();

    // Kurucuyu 0. slota yerleştir
    $insertMember = $db->prepare("
        INSERT INTO room_players (room_id, player_id, slot_index, is_ready, current_hp)
        VALUES (:r, :p, 0, 1, 100)
    ");
    $insertMember->execute([':r' => $roomId, ':p' => $hostPlayerId]);

    Database::sendResponse(true, "Oda başarıyla oluşturuldu.", [
        "room_id" => $roomId,
        "room_code" => $roomCode,
        "stage_seed" => $stageSeed,
        "mode" => $mode
    ], 201);
}

// 3. 6 Haneli Oda Kodu ile Odaya Katıl
if ($action === 'join_room') {
    $playerId = (int)($input['player_id'] ?? 0);
    $roomCode = trim($input['room_code'] ?? '');

    if ($playerId <= 0 || empty($roomCode)) {
        Database::sendResponse(false, "Geçersiz parametreler.", null, 400);
    }

    $findRoom = $db->prepare("SELECT * FROM rooms WHERE room_code = :code AND status = 'waiting' LIMIT 1");
    $findRoom->execute([':code' => $roomCode]);
    $room = $findRoom->fetch();

    if (!$room) {
        Database::sendResponse(false, "Oda bulunamadı veya oyun çoktan başladı.", null, 404);
    }

    $roomId = (int)$room['id'];

    // Doluluk kontrolü
    $countStmt = $db->prepare("SELECT COUNT(*) as count FROM room_players WHERE room_id = :r");
    $countStmt->execute([':r' => $roomId]);
    $currentCount = (int)$countStmt->fetch()['count'];

    if ($currentCount >= (int)$room['max_players']) {
        Database::sendResponse(false, "Oda tamamen dolu!", null, 400);
    }

    // Odaya ekle
    $insert = $db->prepare("
        INSERT INTO room_players (room_id, player_id, slot_index, is_ready, current_hp)
        VALUES (:r, :p, :slot, 0, 100)
        ON DUPLICATE KEY UPDATE is_ready = 0
    ");
    $insert->execute([
        ':r' => $roomId,
        ':p' => $playerId,
        ':slot' => $currentCount,
    ]);

    Database::sendResponse(true, "Odaya başarıyla katıldınız!", $room);
}

// 4. Lobi / Oda Detayı ve Madencileri Getir
if ($action === 'get_room_details') {
    $roomId = (int)($_GET['room_id'] ?? $input['room_id'] ?? 0);
    if ($roomId <= 0) {
        Database::sendResponse(false, "Geçersiz Oda ID.", null, 400);
    }

    $roomStmt = $db->prepare("SELECT * FROM rooms WHERE id = :id LIMIT 1");
    $roomStmt->execute([':id' => $roomId]);
    $room = $roomStmt->fetch();

    if (!$room) {
        Database::sendResponse(false, "Oda bulunamadı.", null, 404);
    }

    $membersStmt = $db->prepare("
        SELECT rp.*, p.player_tag, p.username, p.trophies, p.equipped_skin_id, p.unlocked_stage
        FROM room_players rp
        JOIN players p ON rp.player_id = p.id
        WHERE rp.room_id = :r
        ORDER BY rp.slot_index ASC
    ");
    $membersStmt->execute([':r' => $roomId]);
    $members = $membersStmt->fetchAll();

    $room['players'] = $members;
    Database::sendResponse(true, "Oda detayları getirildi.", $room);
}

// 5. Hazır Olma Durumunu Değiştir
if ($action === 'toggle_ready') {
    $roomId = (int)($input['room_id'] ?? 0);
    $playerId = (int)($input['player_id'] ?? 0);

    $stmt = $db->prepare("
        UPDATE room_players 
        SET is_ready = NOT is_ready, last_ping = NOW() 
        WHERE room_id = :r AND player_id = :p
    ");
    $stmt->execute([':r' => $roomId, ':p' => $playerId]);

    Database::sendResponse(true, "Hazır olma durumu güncellendi.");
}

// 6. Maçı Başlat (Sadece Kurucu)
if ($action === 'start_game') {
    $roomId = (int)($input['room_id'] ?? 0);
    $playerId = (int)($input['player_id'] ?? 0);

    $checkHost = $db->prepare("SELECT host_player_id FROM rooms WHERE id = :r LIMIT 1");
    $checkHost->execute([':r' => $roomId]);
    $host = $checkHost->fetch();

    if (!$host || (int)$host['host_player_id'] !== $playerId) {
        Database::sendResponse(false, "Sadece oda kurucusu maçı başlatabilir.", null, 403);
    }

    $update = $db->prepare("UPDATE rooms SET status = 'in_game' WHERE id = :r");
    $update->execute([':r' => $roomId]);

    Database::sendResponse(true, "Maç başlatıldı! 🌋");
}

Database::sendResponse(false, "Geçersiz istek.", null, 404);
