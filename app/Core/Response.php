<?php
declare(strict_types=1);
namespace HaCrm\Core;
final class Response {
    public static function json(mixed $data, int $status=200): never { http_response_code($status); header('Content-Type: application/json; charset=utf-8'); header('Cache-Control: no-store'); echo json_encode($data, JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES|JSON_INVALID_UTF8_SUBSTITUTE); exit; }
    public static function ok(mixed $data=[], int $status=200): never { self::json(['data'=>$data],$status); }
    public static function error(string $message, int $status=400, array $details=[]): never { self::json(['error'=>['message'=>$message,'details'=>$details]],$status); }
}
