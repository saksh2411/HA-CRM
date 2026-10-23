<?php
declare(strict_types=1);
namespace HaCrm\Security;
use HaCrm\Core\Response;
final class Validator {
    public static function fields(array $data, array $allowed): array { $out=array_intersect_key($data,array_flip($allowed)); foreach ($out as $k=>$v) if (is_string($v)) { $v=trim($v); if (mb_strlen($v)>10000) Response::error("Field {$k} is too long.",422,[$k=>'Maximum length exceeded.']); $out[$k]=$v; } return $out; }
    public static function required(array $data, array $keys): void { $errors=[]; foreach ($keys as $k) if (!isset($data[$k]) || $data[$k]==='') $errors[$k]='Required.'; if ($errors) Response::error('Please correct the highlighted fields.',422,$errors); }
    public static function email(string $email): void { if (!filter_var($email,FILTER_VALIDATE_EMAIL) || strlen($email)>190) Response::error('A valid email address is required.',422,['email'=>'Invalid email.']); }
    public static function money(mixed $value, string $field): string { if (!is_numeric($value) || (float)$value<0 || (float)$value>999999999999) Response::error('Invalid monetary amount.',422,[$field=>'Must be a non-negative amount.']); return number_format((float)$value,2,'.',''); }
}
