<?php
declare(strict_types=1);
$vendorAutoload=dirname(__DIR__).'/vendor/autoload.php';
if(is_file($vendorAutoload)&&is_file(dirname(__DIR__).'/vendor/composer/autoload_real.php')){require_once $vendorAutoload;return;}
spl_autoload_register(static function(string $class): void {
    if($class==='FPDF'){$file=dirname(__DIR__).'/vendor/setasign/fpdf/fpdf.php';if(is_file($file))require_once $file;return;}
    if(str_starts_with($class,'PHPMailer\\PHPMailer\\')){$name=substr($class,strlen('PHPMailer\\PHPMailer\\'));$file=dirname(__DIR__).'/vendor/phpmailer/phpmailer/src/'.$name.'.php';if(is_file($file))require_once $file;return;}
    if(str_starts_with($class,'HaCrm\\')){$relative=str_replace('\\','/',substr($class,strlen('HaCrm\\'))).'.php';$file=__DIR__.'/'.$relative;if(is_file($file))require_once $file;}
});
