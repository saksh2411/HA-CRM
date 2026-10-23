<?php
declare(strict_types=1);
namespace HaCrm\Core;
final class Request {
    public static function method(): string { return strtoupper($_SERVER['REQUEST_METHOD'] ?? 'GET'); }
    public static function path(): string { $path=parse_url($_SERVER['REQUEST_URI'] ?? '/',PHP_URL_PATH) ?: '/'; $base=rtrim(str_replace('\\','/',dirname($_SERVER['SCRIPT_NAME'] ?? '')),'/'); if ($base && str_starts_with($path,$base)) $path=substr($path,strlen($base)); return '/' . trim($path,'/'); }
    public static function body(): array { $raw=file_get_contents('php://input') ?: ''; $data=json_decode($raw,true); if ($raw!=='' && !is_array($data)) Response::error('Request body must be a JSON object.',400); return $data ?? $_POST; }
}
