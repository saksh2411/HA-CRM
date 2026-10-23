<?php
declare(strict_types=1);
if(PHP_SAPI!=='cli'){http_response_code(403);exit('CLI only');}
require dirname(__DIR__).'/app/autoload.php';\HaCrm\Core\Config::load(dirname(__DIR__));(new \HaCrm\Services\AutomationRunner())->overdueInvoices();
