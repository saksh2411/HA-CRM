<?php
declare(strict_types=1);
namespace HaCrm\Core;
use PDO;
final class Database {
    private static ?PDO $pdo = null;
    public static function connection(): PDO {
        if (self::$pdo) return self::$pdo;
        $dsn = 'mysql:host=' . Config::get('DB_HOST','127.0.0.1') . ';port=' . Config::get('DB_PORT','3306') . ';dbname=' . Config::get('DB_NAME','ha_crm_db') . ';charset=utf8mb4';
        self::$pdo = new PDO($dsn, (string)Config::get('DB_USER','root'), (string)Config::get('DB_PASS',''), [PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC,PDO::ATTR_EMULATE_PREPARES=>false,PDO::MYSQL_ATTR_INIT_COMMAND=>"SET time_zone = '+00:00'"]);
        return self::$pdo;
    }
}
