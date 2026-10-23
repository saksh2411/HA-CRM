<?php
declare(strict_types=1);

if (PHP_SAPI !== 'cli') {
    http_response_code(403);
    exit("CLI only.\n");
}

require dirname(__DIR__) . '/app/autoload.php';
\HaCrm\Core\Config::load(dirname(__DIR__));
$db = \HaCrm\Core\Database::connection();

function prompt(string $label): string
{
    fwrite(STDOUT, $label);
    return trim((string) fgets(STDIN));
}

function stop(string $message): never
{
    fwrite(STDERR, $message . PHP_EOL);
    exit(1);
}

$slug = strtolower(prompt('Existing workspace slug: '));
$fullName = prompt('Admin full name: ');
$email = strtolower(prompt('Admin email: '));
$password = prompt('New admin password (input is visible): ');
$confirmation = prompt('Confirm password: ');

if (!preg_match('/^[a-z0-9](?:[a-z0-9-]{1,98}[a-z0-9])$/D', $slug)) {
    stop('Invalid workspace slug.');
}
if ($fullName === '' || mb_strlen($fullName) > 100) {
    stop('Enter an admin name of 1–100 characters.');
}
if (!filter_var($email, FILTER_VALIDATE_EMAIL) || strlen($email) > 190) {
    stop('Enter a valid email address.');
}
if (!hash_equals($password, $confirmation)) {
    stop('Passwords do not match.');
}
if (strlen($password) < 12 || strlen($password) > 72) {
    stop('Password must be 12–72 bytes long.');
}

$workspace = $db->prepare("SELECT id FROM tenants WHERE slug=? AND status='active' LIMIT 1");
$workspace->execute([$slug]);
$tenantId = (int) $workspace->fetchColumn();
if (!$tenantId) {
    stop('Active workspace not found.');
}
$users = $db->prepare('SELECT COUNT(*) FROM users WHERE tenant_id=?');
$users->execute([$tenantId]);
if ((int) $users->fetchColumn() !== 0) {
    stop('This workspace already has a user.');
}

$db->beginTransaction();
try {
    $lock = $db->prepare("SELECT id FROM tenants WHERE id=? AND status='active' FOR UPDATE");
    $lock->execute([$tenantId]);
    if (!$lock->fetchColumn()) {
        throw new RuntimeException('Active workspace not found.');
    }
    $users->execute([$tenantId]);
    if ((int) $users->fetchColumn() !== 0) {
        throw new RuntimeException('This workspace already has a user.');
    }
    $db->prepare('INSERT IGNORE INTO roles(tenant_id,name) VALUES(?,\'Admin\')')->execute([$tenantId]);
    $db->prepare("INSERT IGNORE INTO role_permissions(role_id,permission_id) SELECT r.id,p.id FROM roles r CROSS JOIN permissions p WHERE r.tenant_id=? AND r.name='Admin'")->execute([$tenantId]);
    $insert = $db->prepare("INSERT INTO users(tenant_id,full_name,email,password_hash,role,status) VALUES(?,?,?,?,'Admin','Active')");
    $insert->execute([$tenantId, $fullName, $email, \HaCrm\Security\Password::hash($password)]);
    $db->commit();
    fwrite(STDOUT, "Admin created for workspace {$slug}. Sign in with the email and password you entered.\n");
} catch (\Throwable $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    if ($e instanceof RuntimeException) {
        stop($e->getMessage());
    }
    stop($e->getCode() === '23000' ? 'A conflicting workspace user already exists.' : 'Admin setup failed; review the PHP error log.');
}
