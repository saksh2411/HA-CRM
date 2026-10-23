<?php
declare(strict_types=1);
namespace HaCrm\Security;
final class SmtpCipher {
    public static function encrypt(string $plain,string $appKey): string {if(strlen($appKey)<24)throw new \RuntimeException('APP_KEY must contain at least 24 characters.');$iv=random_bytes(12);$tag='';$cipher=openssl_encrypt($plain,'aes-256-gcm',hash('sha256',$appKey,true),OPENSSL_RAW_DATA,$iv,$tag);if($cipher===false)throw new \RuntimeException('Could not encrypt SMTP credential.');return base64_encode($iv.$tag.$cipher);}
    public static function decrypt(string $encoded,string $appKey): string {if(strlen($appKey)<24)throw new \RuntimeException('APP_KEY must contain at least 24 characters.');$raw=base64_decode($encoded,true);if($raw===false||strlen($raw)<28)throw new \RuntimeException('Stored SMTP credential is invalid.');$plain=openssl_decrypt(substr($raw,28),'aes-256-gcm',hash('sha256',$appKey,true),OPENSSL_RAW_DATA,substr($raw,0,12),substr($raw,12,16));if($plain===false)throw new \RuntimeException('Could not decrypt SMTP credential. Check APP_KEY.');return $plain;}
}
