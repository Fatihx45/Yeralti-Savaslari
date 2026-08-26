<?php
// ==========================================================
// Yeraltı Savaşları - Arkadaşlık & Sosyal Sistem API'si
// ==========================================================

require_once __DIR__ . '/../config/database.php';

$db = (new Database())->getConnection();
$input = Database::getJsonInput();
$action = $_GET['action'] ?? $input['action'] ?? 'list_friends';

// 1. Arkadaş Listesini Getir
if ($action === 'list_friends') {
    $playerId = (int)($_GET['player_id'] ?? $input['player_id'] ?? 0);
    if ($playerId <= 0) {
        Database::sendResponse(false, "Geçersiz Oyuncu ID.", null, 400);
    }

    $stmt = $db->prepare("
        SELECT 
            p.id, p.player_tag, p.username, p.trophies, p.unlocked_stage, 
            p.equipped_skin_id, p.status, f.gift_available, f.status as friendship_status
        FROM friends f
        JOIN players p ON f.friend_id = p.id
        WHERE f.player_id = :player_id
        ORDER BY p.status ASC, p.trophies DESC
    ");
    $stmt->execute([':player_id' => $playerId]);
    $friends = $stmt->fetchAll();

    Database::sendResponse(true, "Arkadaşlar listelendi.", $friends);
}

// 2. #TAG ile Oyuncu Ara
if ($action === 'search_tag') {
    $query = trim($_GET['tag'] ?? $input['tag'] ?? '');
    if (empty($query)) {
        Database::sendResponse(false, "Arama etiketi boş bırakılamaz.", null, 400);
    }

    // Eğer başında # yoksa ekle
    if (!str_starts_with($query, '#') && is_numeric($query)) {
        $query = '#' . $query;
    }

    $stmt = $db->prepare("
        SELECT id, player_tag, username, trophies, unlocked_stage, equipped_skin_id, status 
        FROM players 
        WHERE player_tag = :tag OR username LIKE :name
        LIMIT 10
    ");
    $stmt->execute([
        ':tag' => $query,
        ':name' => "%$query%"
    ]);
    $results = $stmt->fetchAll();

    Database::sendResponse(true, "Arama tamamlandı.", $results);
}

// 3. Arkadaş Ekle (#TAG veya ID ile)
if ($action === 'add_friend') {
    $playerId = (int)($input['player_id'] ?? 0);
    $friendTag = trim($input['friend_tag'] ?? '');

    if ($playerId <= 0 || empty($friendTag)) {
        Database::sendResponse(false, "Eksik parametreler.", null, 400);
    }

    $find = $db->prepare("SELECT id FROM players WHERE player_tag = :tag LIMIT 1");
    $find->execute([':tag' => $friendTag]);
    $target = $find->fetch();

    if (!$target) {
        Database::sendResponse(false, "Bu etikete sahip madenci bulunamadı.", null, 404);
    }

    $targetId = (int)$target['id'];
    if ($targetId === $playerId) {
        Database::sendResponse(false, "Kendinizi arkadaş olarak ekleyemezsiniz.", null, 400);
    }

    // Çift taraflı arkadaşlık kaydı oluştur
    $insert1 = $db->prepare("INSERT IGNORE INTO friends (player_id, friend_id, status) VALUES (:p, :f, 'accepted')");
    $insert1->execute([':p' => $playerId, ':f' => $targetId]);

    $insert2 = $db->prepare("INSERT IGNORE INTO friends (player_id, friend_id, status) VALUES (:p, :f, 'accepted')");
    $insert2->execute([':p' => $targetId, ':f' => $playerId]);

    Database::sendResponse(true, "Madenci arkadaş listenize eklendi! 👥");
}

// 4. Hediye Gönder / Al
if ($action === 'claim_gift') {
    $playerId = (int)($input['player_id'] ?? 0);
    $friendId = (int)($input['friend_id'] ?? 0);

    $stmt = $db->prepare("UPDATE friends SET gift_available = 0 WHERE player_id = :p AND friend_id = :f");
    $stmt->execute([':p' => $playerId, ':f' => $friendId]);

    Database::sendResponse(true, "Hediye altın toplandı! (+50 Altın)", ["reward_gold" => 50]);
}

Database::sendResponse(false, "Geçersiz istek.", null, 404);
