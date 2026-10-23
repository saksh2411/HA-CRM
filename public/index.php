<?php
declare(strict_types=1);
use HaCrm\Core\{Config,Response};
use HaCrm\Domain\Api;
require dirname(__DIR__).'/app/autoload.php';
Config::load(dirname(__DIR__));
ini_set('session.use_strict_mode','1');ini_set('session.use_only_cookies','1');
ini_set('session.gc_maxlifetime','7200');
$secure=(Config::get('SESSION_SECURE','false')==='true') || (!empty($_SERVER['HTTPS'])&&$_SERVER['HTTPS']!=='off');
session_name('ha_crm_session'); session_set_cookie_params(['lifetime'=>0,'path'=>'/','secure'=>$secure,'httponly'=>true,'samesite'=>'Lax']); session_start();
header('X-Content-Type-Options: nosniff');header('X-Frame-Options: DENY');header('Referrer-Policy: strict-origin-when-cross-origin');header('Permissions-Policy: camera=(), microphone=(), geolocation=()');
header("Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; font-src 'self' data:; connect-src 'self'; frame-ancestors 'none'; base-uri 'self'; form-action 'self'");
if($secure)header('Strict-Transport-Security: max-age=31536000; includeSubDomains');
if(isset($_SESSION['user'])){if(($_SESSION['last_activity']??time())<time()-7200){$_SESSION=[];session_regenerate_id(true);}$_SESSION['last_activity']=time();}
if (str_starts_with(\HaCrm\Core\Request::path(),'/api')) {
    try {(new Api())->dispatch();} catch(Throwable $e) {
        $rid=bin2hex(random_bytes(8)); error_log("HA-CRM {$rid}: ".$e->getMessage());
        $status=$e instanceof PDOException?503:500; Response::error($status===503?'Service temporarily unavailable.':'Request could not be completed. Reference '.$rid,$status);
    }
}
$built=__DIR__.'/assets/build/index.html';
if (is_file($built)) { header('Content-Type: text/html; charset=utf-8');$html=file_get_contents($built);$base=rtrim(str_replace('\\','/',dirname($_SERVER['SCRIPT_NAME']??'')),'/');$assetBase=$base.'/assets/build/assets/';$html=str_replace('./assets/',$assetBase,$html);$baseHtml=htmlspecialchars($base,ENT_QUOTES|ENT_SUBSTITUTE,'UTF-8');$bootstrap='<meta name="ha-crm-base" content="'.$baseHtml.'"></head>';$html=str_replace('</head>',$bootstrap,$html);echo $html;exit; }
header('Content-Type: text/html; charset=utf-8'); echo '<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>HA CRM setup</title></head><body><div id="root"></div><script type="module" src="/resources/frontend/src/main.jsx"></script></body></html>';
