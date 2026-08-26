<?php
// ==========================================================
// Yeraltı Savaşları - cPanel Veritabanı ve Yapılandırma Dosyası
// ==========================================================

// CORS (Cross-Origin Resource Sharing) ve JSON Başlıkları
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

// OPTIONS isteklerini hızlıca yanıtla (Preflight)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

class Database {
    // ⬇️ cPanel Veritabanı Bilgilerinizi Buraya Giriniz ⬇️
    private string $host = "localhost";
    private string $db_name = "derin_kazi_db";   // Örn: cpaneluser_derinkazi
    private string $username = "root";           // Örn: cpaneluser_dbuser
    private string $password = "";               // Örn: GucluSifre123!
    public ?PDO $conn = null;

    public function getConnection(): ?PDO {
        $this->conn = null;
        try {
            $dsn = "mysql:host=" . $this->host . ";dbname=" . $this->db_name . ";charset=utf8mb4";
            $options = [
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES   => false,
            ];
            $this->conn = new PDO($dsn, $this->username, $this->password, $options);
        } catch (PDOException $exception) {
            self::sendResponse(false, "Veritabanı bağlantı hatası: " . $exception->getMessage(), null, 500);
            exit();
        }
        return $this->conn;
    }

    public static function getJsonInput(): array {
        $raw = file_get_contents("php://input");
        if (empty($raw)) return [];
        $data = json_decode($raw, true);
        return is_array($data) ? $data : [];
    }

    public static function sendResponse(bool $success, string $message, mixed $data = null, int $statusCode = 200): void {
        http_response_code($statusCode);
        echo json_encode([
            "success" => $success,
            "message" => $message,
            "data" => $data,
            "timestamp" => time()
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }
}
