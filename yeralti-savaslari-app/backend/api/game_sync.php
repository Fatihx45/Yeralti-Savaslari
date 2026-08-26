<?php
// ==========================================================
// Yeraltı Savaşları - Canlı Maç Senkronizasyonu & Olay Kuyruğu API'si
// ==========================================================

require_once __DIR__ . '/../config/database.php';

$db = (new Database())->getConnection();
$input = Database::getJsonInput();
$action = $_GET['action'] ?? $input['action'] ?? 'sync';

// 1. Yeni Olay Gönder (Kutu Kırma, Mermi Ateşleme, Can Hasarı, Emoji)
if ($action === 'push_event') {
    $roomId = (int)($input['room_id'] ?? 0);
    $senderId = (int)($input['player_id'] ?? 0);
    $eventType = trim($input['event_type'] ?? '');
    $payload = is_array($input['payload'] ?? null) ? json_encode($input['payload']) : trim($input['payload'] ?? '{}');

    if ($roomId <= 0 || $senderId <= 0 || empty($eventType)) {
        Database::sendResponse(false, "Eksik olay verisi.", null, 400);
    }

    $insert = $db->prepare("
        INSERT INTO game_events (room_id, sender_player_id, event_type, payload_json)
        VALUES (:r, :p, :type, :payload)
    ");
    $insert->execute([
        ':r' => $roomId,
        ':p' => $senderId,
        ':type' => $eventType,
        ':payload' => $payload,
    ]);

    Database::sendResponse(true, "Olay kaydedildi.", ["event_id" => $db->lastInsertId()]);
}

// 2. Yeni Olayları Çek (Polling Senkronizasyonu)
if ($action === 'fetch_events') {
    $roomId = (int)($_GET['room_id'] ?? $input['room_id'] ?? 0);
    $lastEventId = (int)($_GET['last_event_id'] ?? $input['last_event_id'] ?? 0);

    if ($roomId <= 0) {
        Database::sendResponse(false, "Geçersiz Oda ID.", null, 400);
    }

    $stmt = $db->prepare("
        SELECT id, sender_player_id, event_type, payload_json, created_at
        FROM game_events
        WHERE room_id = :r AND id > :last_id
        ORDER BY id ASC
        LIMIT 50
    ");
    $stmt->execute([':r' => $roomId, ':last_id' => $lastEventId]);
    $rawEvents = $stmt->fetchAll();

    $events = [];
    foreach ($rawEvents as $row) {
        $events[] = [
            "id" => (int)$row['id'],
            "sender_player_id" => (int)$row['sender_player_id'],
            "event_type" => $row['event_type'],
            "payload" => json_decode($row['payload_json'], true) ?? $row['payload_json'],
            "created_at" => $row['created_at'],
        ];
    }

    Database::sendResponse(true, "Olaylar getirildi.", $events);
}

// 3. Canlı Oyuncu Can & Skor Güncelleme
if ($action === 'update_player_stats') {
    $roomId = (int)($input['room_id'] ?? 0);
    $playerId = (int)($input['player_id'] ?? 0);
    $currentHp = (int)($input['current_hp'] ?? 100);
    $score = (int)($input['score'] ?? 0);
    $isAlive = (int)($input['is_alive'] ?? 1);

    $stmt = $db->prepare("
        UPDATE room_players
        SET current_hp = :hp, score = :score, is_alive = :alive, last_ping = NOW()
        WHERE room_id = :r AND player_id = :p
    ");
    $stmt->execute([
        ':hp' => $currentHp,
        ':score' => $score,
        ':alive' => $isAlive,
        ':r' => $roomId,
        ':p' => $playerId,
    ]);

    Database::sendResponse(true, "İstatistikler güncellendi.");
}

Database::sendResponse(false, "Geçersiz istek.", null, 404);
