<?php
declare(strict_types=1);
namespace HaCrm\Support;
use DateTimeImmutable;
use DateTimeZone;
use HaCrm\Core\Response;
final class UtcTime {
    public static function normalize(mixed $value,string $tenantZone,string $field): ?string {if($value===null||$value==='')return null;try{$text=(string)$value;$hasOffset=(bool)preg_match('/(?:Z|[+-]\d{2}:?\d{2})$/i',$text);$date=new DateTimeImmutable(str_replace('T',' ',$text),new DateTimeZone($hasOffset?'UTC':$tenantZone));return $date->setTimezone(new DateTimeZone('UTC'))->format('Y-m-d H:i:s');}catch(\Throwable){Response::error('Invalid date or time.',422,[$field=>'Invalid date/time.']);}}
}
