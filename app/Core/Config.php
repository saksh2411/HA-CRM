<?php
declare(strict_types=1);
namespace HaCrm\Core;
final class Config {
    private static array $values = [];
    public static function load(string $root): void {
        date_default_timezone_set('UTC');
        $file = $root . '/.env';
        if (is_file($file)) foreach (file($file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) ?: [] as $line) {
            $line = trim($line); if ($line === '' || str_starts_with($line, '#') || !str_contains($line, '=')) continue;
            [$key,$value] = explode('=', $line, 2); self::$values[trim($key)] = trim(trim($value), " \\\"'");
        }
    }
    public static function get(string $key, mixed $default = null): mixed { return self::$values[$key] ?? (getenv($key) ?: $default); }
}
