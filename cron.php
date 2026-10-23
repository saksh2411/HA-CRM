<?php
declare(strict_types=1);
if(PHP_SAPI!=='cli') { http_response_code(403); exit('CLI only'); }
require __DIR__.'/app/autoload.php';\HaCrm\Core\Config::load(__DIR__);
(new \HaCrm\Services\AutomationRunner())->run();
