<?php
// ==========================================================
// Yeraltı Savaşları - Kimlik Doğrulama & Oyuncu Kayıt API'si
// ==========================================================

require_once __DIR__ . '/../config/database.php';

$db = (new Database())->getConnection();
$input = Database::getJsonInput();
$action = $_GET['action'] ?? $input['action'] ?? 'login_or_register';

if ($action === 'login_or_register') {
    $username = trim($input['username'] ?? 'Madenci');
    $playerTag = trim($input['player_tag'] ?? '');

    if (empty($username)) {
        Database::sendResponse(false, "Kullanıcı adı boş bırakılamaz.", null, 400);
    }

    // 1. Eğer oyuncunun kayıtlı bir #TAG'i varsa bul
    if (!empty($playerTag)) {
        $stmt = $db->prepare("SELECT * FROM players WHERE player_tag = :tag LIMIT 1");
        $stmt->execute([':tag' => $playerTag]);
        $player = $stmt->fetch();

        if ($player) {
            // Son görülme güncelle
            $update = $db->prepare("UPDATE players SET username = :username, status = 'online', last_seen = NOW() WHERE id = :id");
            $update->execute([':username' => $username, ':id' => $player['id']]);

            Database::sendResponse(true, "Giriş başarılı.", $player);
        }
    }

    // 2. Yeni Oyuncu Kaydı ve Benzersiz #TAG Üretimi
    $generatedTag = '';
    $attempts = 0;
    do {
        $generatedTag = '#' . str_pad((string)rand(1000, 9999), 4, '0', STR_PAD_LEFT);
        $checkStmt = $db->prepare("SELECT id FROM players WHERE player_tag = :tag LIMIT 1");
        $checkStmt->execute([':tag' => $generatedTag]);
        $attempts++;
    } while ($checkStmt->fetch() && $attempts < 20);

    $insert = $db->prepare("
        INSERT INTO players (player_tag, username, trophies, unlocked_stage, gold, gems, status, last_seen)
        VALUES (:tag, :username, 100, 1, 150, 15, 'online', NOW())
    ");
    $insert->execute([
        ':tag' => $generatedTag,
        ':username' => $username,
    ]);

    $newId = $db->lastInsertId();
    $stmt = $db->prepare("SELECT * FROM players WHERE id = :id LIMIT 1");
    $stmt->execute([':id' => $newId]);
    $newPlayer = $stmt->fetch();

    Database::sendResponse(true, "Yeni madenci kaydı oluşturuldu.", $newPlayer, 201);
}

if ($action === 'update_profile') {
    $playerId = (int)($input['player_id'] ?? 0);
    $trophies = (int)($input['trophies'] ?? 0);
    $stage = (int)($input['unlocked_stage'] ?? 1);
    $gold = (int)($input['gold'] ?? 0);
    $gems = (int)($input['gems'] ?? 0);
    $skin = trim($input['equipped_skin_id'] ?? 'skin_miner_default');

    if ($playerId <= 0) {
        Database::sendResponse(false, "Geçersiz Oyuncu ID.", null, 400);
    }

    $stmt = $db->prepare("
        UPDATE players 
        SET trophies = :trophies, unlocked_stage = :stage, gold = :gold, gems = :gems, equipped_skin_id = :skin, last_seen = NOW()
        WHERE id = :id
    ");
    $stmt->execute([
        ':trophies' => $trophies,
        ':stage' => $stage,
        ':gold' => $gold,
        ':gems' => $gems,
        ':skin' => $skin,
        ':id' => $playerId,
    ]);

    Database::sendResponse(true, "Profil güncellendi.");
}

Database::sendResponse(false, "Bilinmeyen istek.", null, 404);
